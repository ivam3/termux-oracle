# OmniRoute: adaptación de una app Node.js con dependencias nativas para Termux/Android

Este documento describe la arquitectura y proceso completo para adaptar **OmniRoute** (app Node.js con dependencias C++ nativas y playwright-core) para ejecutarse nativamente en Termux/Android sin proot. Sirve como referencia para adaptar cualquier aplicación Node.js similar que enfrente los mismos desafíos de plataforma en Android.

---

## El Problema Técnico

OmniRoute presenta tres desafíos de adaptación para Termux:

### 1. process.platform === "android"

Node.js en Termux reporta `process.platform === "android"`. Muchas librerías (especialmente playwright-core) verifican explícitamente este valor contra `"linux"`, `"darwin"` o `"win32"` y lanzan excepción si no coincide. En OmniRoute, `playwright-core` es una dependencia directa y su carga ocurre en el momento del `require()` inicial.

Archivos afectados en playwright-core v1.52:

| Archivo | Línea | Patrón |
|---------|-------|--------|
| `lib/coreBundle.js` | 28600, 51284, 68854 | IIFE: `if (p === "linux") ... throw Error(...)` |
| `lib/serverRegistry.js` | 7286 | IIFE: `if (p === "linux") ... throw Error(...)` |
| `lib/tools/cli-client/registry.js` | 130 | `if (!localCacheDir) throw Error(...)` |

### 2. better-sqlite3 (addon nativo C++)

`better-sqlite3` compila un bindings nativo (`better_sqlite3.node`) via `node-gyp` durante `npm install`. En Termux esto funciona porque Termux provee las cabeceras de Node.js y las herramientas de compilación (clang, make, python). Sin embargo:

- El binario se compila para `$INSTALL_DIR/node_modules/better-sqlite3/build/Release/`
- OmniRoute busca el módulo desde `dist/node_modules/better-sqlite3/`
- Es necesario copiar el `.node` compilado a la ruta que espera el bundle

### 3. Dependencias opcionales: Chromium

OmniRoute puede usar playwright para funcionalidades de navegador. En Android esto requiere Chromium headless, que a su vez requiere un entorno glibc completo con librerías GTK, X11, NSS, etc. que no existen en Bionic. La solución es `playwright-proot` (Chromium via proot-distro Ubuntu).

---

## La Solución: Adaptación por capas

### Capa 1: Mock de playwright-core (crash prevention)

El enfoque más simple y robusto es envolver el `require('playwright-core')` en un try/catch dentro del entry point de la librería:

```javascript
// playwright-core/index.js (parcheado por postinst)
try {
  require('./lib/bootstrap');
  module.exports = require('./lib/coreBundle').inprocess.playwright;
} catch (e) {
  if (e && e.message && e.message.includes('Unsupported platform')) {
    module.exports = {
      chromium: {}, firefox: {}, webkit: {},
      selectors: {}, devices: {}, errors: {},
      _android: { launcher: {} }
    };
  } else {
    throw e;
  }
}
```

**Ventajas:**
- 100% seguro — no modifica el comportamiento interno de playwright
- Funciona sin proot, sin root, sin dependencias extra
- El dashboard de OmniRoute carga completo

**Desventajas:**
- Las funciones de navegador (screenshot, eval, snapshot) lanzan error informativo
- No es posible usar playwright-directo desde OmniRoute

### Capa 2: Parcheo de platform checks (full browser support)

Para habilitar playwright completamente, se parchean los 5 archivos que verifican `process.platform` usando sed:

```bash
# En cada archivo, reemplazar:
#   if (process.platform === "linux")
# por:
#   if (process.platform === "linux" || process.platform === "android")

sed -i \
  -e 's/if (process.platform === "linux")/if (process.platform === "linux" || process.platform === "android")/g' \
  lib/coreBundle.js lib/serverRegistry.js lib/tools/cli-client/registry.js
```

Esto hace que los IIFEs de determinación de cache directory tomen la rama Linux cuando `process.platform === "android"`, y los throws nunca se ejecutan.

**Ventajas:**
- playwright-core carga completamente
- Se puede conectar a Chromium via CDP (`playwright-proot`)
- Sin modificaciones al flujo de control interno

**Desventajas:**
- Chromium requiere playwright-proot (glibc + proot)
- El parcheo debe re-aplicarse si npm reinstala playwright-core

### Capa 3: Instalación de playwright-proot

Si el usuario necesita funcionalidad de navegador, instala el paquete complementario:

```bash
apt install playwright-proot
```

Esto configura:
1. proot-distro Ubuntu (entorno glibc completo)
2. Librerías del sistema para Chromium (GTK, NSS, X11, etc.)
3. Node.js + @playwright/cli dentro de Ubuntu
4. Chromium headless (arm64)

OmniRoute se conecta a Chromium via CDP en `localhost:9222`.

---

## Arquitectura del postinst

```
postinst (apt install omniroute)
│
├── 1. Crear package.json + .npmrc en ~/.local/share/omniroute/
│
├── 2. npm install --production --no-audit --no-fund
│   ├── Descarga omniroute + dependencias
│   └── better-sqlite3 compila addon nativo (node-gyp)
│
├── 3. Rebuild better-sqlite3
│   ├── cd node_modules/better-sqlite3
│   ├── npm rebuild
│   └── cp better_sqlite3.node → dist/node_modules/better-sqlite3/build/Release/
│
├── 4. Patch playwright-core
│   └── patch-playwright.sh --mock
│       └── try/catch wrapper en playwright-core/index.js
│
├── 5. Crear symlink: $PREFIX/bin/omniroute → node_modules/omniroute/bin/omniroute.mjs
│
└── 6. Instalar fixer (script de diagnóstico i-HakLab)
```

### Script patch-playwright.sh

Script autónomo que maneja el parcheo de playwright-core en múltiples copias:

| Modo | Acción | Uso |
|------|--------|-----|
| `--mock` | try/catch stub en index.js | `patch-playwright.sh --mock` |
| `--full` | stub + parcheo platform checks | `patch-playwright.sh --full` |
| `--status` | diagnostico de cada copia | `patch-playwright.sh --status` |
| `--restore` | restaurar backups | `patch-playwright.sh --restore` |
| `auto` | detecta playwright-proot | `patch-playwright.sh` |

Busca automáticamente copias de playwright-core en:
- `$INSTALL_DIR/node_modules/playwright-core/`
- `$INSTALL_DIR/node_modules/omniroute/dist/node_modules/playwright-core/`
- `$HOME/.npm/_npx/*/node_modules/playwright-core/`

---

## Mapeo de archivos

| Ruta en paquete .deb | Destino en dispositivo | Propósito |
|----------------------|------------------------|-----------|
| `manifiest.json` | metadato del paquete | Define depends, suggests, files |
| `postinst` | script post-instalación | npm install, rebuild, patch, symlink |
| `lib/patch-playwright.sh` | `$PREFIX/lib/omniroute/patch-playwright.sh` | Parcheo condicional de playwright-core |
| `DEBIAN/control` | control del .deb | Metadatos dpkg |

---

## Lecciones para adaptar otras apps Node.js a Android

### Checklist de adaptación

1. **Detectar `process.platform` checks** — buscar `process.platform ===` en node_modules. Si hay comparaciones rígidas con solo `"linux"`, `"darwin"`, `"win32"`, se necesita parche.

2. **Detectar `Unsupported platform` throws** — buscar `throw` con `"Unsupported platform"`. Cada uno es un punto de fallo.

3. **Manejar módulos nativos C++** — `node-gyp` funciona en Termux si hay `clang`, `make`, `python`. Verificar que `npm rebuild` compile y que el `.node` generado esté accesible desde donde la app lo busca.

4. **Estrategia de parcheo:**
   - **Mock temprano (recomendado):** try/catch en el require principal.
   - **Parcheo directo:** sed para reemplazar strings de platform check.
   - **Variables de entorno:** algunas librerías respetan `PLAYWRIGHT_BROWSERS_PATH`, `XDG_CACHE_HOME`, etc.

5. **Dependencias glibc opcionales:** si la app necesita Chromium, Electron, o similares, se requiere proot-distro (no basta con el bridge glibc básico).

6. **Documentar en postinst:** todo el proceso debe ser reproducible automáticamente con `apt install`.

### Referencias

- [Adaptación de binarios glibc en Termux](./compilacion-glibc.md)
- [Playwright-proot: Chromium headless en Termux](./playwright-proot.md)
- [Repositorio del paquete omniroute](https://github.com/ivam3/termux-packages/tree/master/packages/omniroute)
- [OmniRoute upstream](https://github.com/diegosouzapw/OmniRoute)
- [Limitaciones de Android para binarios glibc](../android/bypass-limitaciones.md)
