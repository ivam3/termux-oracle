# OmniRoute (omniroute)

## ¿Qué es OmniRoute?

**OmniRoute** es un gestor de rutas de API, proxy inverso y panel de administración web todo-en-uno construido en Node.js. Proporciona una interfaz web (dashboard) para gestionar y enrutar tráfico HTTP/HTTPS, actuar como gateway API, exponer servicios locales de forma segura y ejecutar comandos del sistema desde el navegador.

## ¿Para qué es útil la herramienta?

- **API Gateway:** Centraliza múltiples servicios backend bajo un mismo punto de entrada con reglas de enrutamiento dinámicas.
- **Proxy inverso:** Redirige tráfico hacia servidores internos con balanceo de carga y reescritura de cabeceras.
- **Dashboard web:** Panel de administración accesible desde el navegador para monitorizar rutas, tráfico y estado de servicios.
- **CLI vía web:** Ejecuta comandos del sistema directamente desde el dashboard.
- **Despliegue rápido:** Ideal para entornos Android/Termux donde se necesita exponer servicios sin configurar nginx/Apache manualmente.

## Instalación

```bash
# Mediante el wrapper de i-HakLab:
apt install omniroute

# El postinst configura automáticamente:
# 1. Node.js + npm (si no existen)
# 2. Crea el directorio de instalacion en ~/.local/share/omniroute
# 3. Descarga e instala omniroute via npm
# 4. Reconstruye modulos nativos (better-sqlite3)
# 5. Parchea playwright-core para compatibilidad Android
# 6. Instala el binario 'omniroute' en PATH
```

## ¿Cómo se usa? (Ejemplos básicos)

```bash
# Iniciar el servidor web
omniroute serve

# Verificar instalacion
omniroute --version

# Conocer el estado del servicio
omniroute status
```

Acceder al dashboard en `http://localhost:20128`. La primera vez se debe establecer una contraseña (por defecto en versiones recientes: `123456`).

## Proceso de adaptación para Android

OmniRoute no fue diseñado originalmente para Android/Termux. Su adaptación requirió resolver dos problemas técnicos principales:

### 1. better-sqlite3 (módulo nativo C++)

`better-sqlite3` compila un addon nativo (`better_sqlite3.node`) durante `npm install`. En Termux (Bionic libc, ARM64), la compilación funciona correctamente usando `npm rebuild`, pero el binario compilado debe copiarse manualmente al directorio `dist/` si la aplicación busca el módulo desde una ruta diferente.

**Solución:** el `postinst` ejecuta `npm rebuild` dentro de `node_modules/better-sqlite3` y copia el `.node` resultante a `dist/node_modules/better-sqlite3/build/Release/`.

### 2. playwright-core (verificación de plataforma)

Playwright-core verifica `process.platform === "linux"` o `"darwin"` o `"win32"` y lanza `throw new Error("Unsupported platform: " + process.platform)` si no coincide. En Termux, `process.platform` retorna `"android"`, lo que causa que el `require('playwright-core')` completo falle.

**Solución de dos capas:**

- **Capa 1 (mock stub):** Se envuelve el `require()` de `playwright-core/index.js` en un try/catch. Si falla por "Unsupported platform", se exporta un objeto stub vacío (`{ chromium: {}, firefox: {}, ... }`). Esto evita el crash y permite que el dashboard funcione, pero sin navegador.

- **Capa 2 (full patch, opcional):** Cuando se instala `playwright-proot`, se parchean los 5 archivos que contienen el check de plataforma (`coreBundle.js`, `serverRegistry.js`, `cli-client/registry.js`) reemplazando `process.platform === "linux"` por `process.platform === "linux" || process.platform === "android"`. Esto permite que playwright cargue completamente y se conecte a Chromium via CDP dentro de proot.

### 3. Script patch-playwright.sh

Se creó un script autónomo con 4 modos:
- `--mock`: aplica solo el stub (crash prevention)
- `--full`: aplica stub + parcheo de platform checks
- `--status`: muestra el estado de cada copia de playwright-core
- `auto`: detecta si playwright-proot está instalado y aplica el modo correspondiente

## Consideraciones Adicionales

- **Puerto por defecto:** `20128` (configurable via variables de entorno).
- **Persistencia:** La configuracion se almacena en SQLite en `~/.omniroute/`.
- **Navegador / Web Automation:** Para funcionalidades que requieran Chromium, instalar: `apt install playwright-proot`.
- **Dependencias:** Requiere Node.js 20+ instalado.
- **Reset de contraseña:** Detener omniroute, eliminar `~/.omniroute/omniroute.db`, reiniciar.

---
*Nota: Esta herramienta integra un gestor de rutas API con dashboard web en el ecosistema i-Haklab. Su adaptación para Android es un ejemplo de cómo empaquetar aplicaciones Node.js con dependencias nativas y de plataforma en Termux.*
