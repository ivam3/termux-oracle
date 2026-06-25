# Playwright-cli para Termux via proot-distro Ubuntu 🎭

Este documento describe la arquitectura y método para ejecutar **Playwright CLI** (automatización de navegador) en Termux/Android utilizando **proot-distro Ubuntu** como contenedor glibc completo.

---

## 🔬 El Problema Técnico

Playwright CLI + Chromium requieren un entorno **glibc** completo con ~31 librerías compartidas que incluyen:

| Categoría | Librerías |
|-----------|-----------|
| Core glibc | libc.so.6, libdl.so.2, libpthread.so.0, libm.so.6 |
| GTK/GLib | libglib-2.0.so.0, libgobject-2.0.so.0, libgio-2.0.so.0, libcairo.so.2, libpango-1.0.so.0, libatk-1.0.so.0, libatk-bridge-2.0.so.0, libatspi.so.0 |
| X11 | libX11.so.6, libxcb.so.1, libXext.so.6, libXcomposite.so.1, libXdamage.so.1, libXfixes.so.3, libXrandr.so.2, libxkbcommon.so.0 |
| NSS | libnspr4.so, libnss3.so, libnssutil3.so, libsmime3.so |
| Sistema | libdbus-1.so.3, libcups.so.2, libexpat.so.1, libasound.so.2, libgbm.so.1, libudev.so.1, libgcc_s.so.1 |

En Termux nativo (Bionic libc) varias de estas librerías no existen en los repos glibc (`libxdamage-glibc`, `atk-glibc`, `at-spi2-core-glibc`, `nss-glibc`, `nspr-glibc`, `cups-glibc`, `udev-glibc`), y además se necesitan servicios del sistema (D-Bus, udev) que Android no provee.

---

## 🛠️ La Solución: proot-distro Ubuntu

En lugar del enfoque de bootstrapper C usado para herramientas como `opencode` (que solo necesitan libc core), Chromium requiere un entorno **glibc completo con system services**. `proot-distro ubuntu` proporciona:

- ✅ glibc completo con todas las librerías
- ✅ Resolución de dependencias via `apt`
- ✅ Network namespace compartido (localhost directo al host)
- ✅ Sistema de archivos compartido via `--shared-tmp`

### Limitación conocida

El "Enable accessibility" button de Flet/Flutter es el único elemento en el árbol de accesibilidad. Los elementos renderizados por CanvasKit no son accesibles como DOM nodes. Para testing funcional, usar `screenshot` + `snapshot` + `eval` en lugar de `click`.

---

## 📦 Instalación

### Via paquete .deb (recomendado)

```bash
apt install playwright-proot
```

El `postinst` automatiza:
1. `proot-distro install ubuntu` (si no existe)
2. `apt install -y libglib2.0-0t64 libnss3 libnspr4 libdbus-1-3 libatk1.0-0t64 libatk-bridge2.0-0t64 libcups2t64 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libgbm1 libpango-1.0-0 libcairo2 libasound2t64 libatspi2.0-0t64 libudev1`
3. `curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && apt install -y nodejs`
4. `npm install -g @playwright/cli@latest`
5. `playwright-cli install-browser chromium`

### Manual

```bash
# 1. Instalar Ubuntu
proot-distro install ubuntu

# 2. Librerías del sistema
proot-distro login ubuntu --shared-tmp -- /bin/bash -c '
    apt update && apt install -y libglib2.0-0t64 libnss3 libnspr4 \
        libdbus-1-3 libatk1.0-0t64 libatk-bridge2.0-0t64 libcups2t64 \
        libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 \
        libxrandr2 libgbm1 libpango-1.0-0 libcairo2 libasound2t64 \
        libatspi2.0-0t64 libudev1
'

# 3. Node.js + playwright-cli + Chromium
proot-distro login ubuntu --shared-tmp -- /bin/bash -c '
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
    apt install -y nodejs
    npm install -g @playwright/cli@latest
    playwright-cli install-browser chromium
'
```

---

## 🚀 Uso

### 1. Iniciar la app target en Termux (host)
```bash
flet run --web --port 8550 main.py
```

### 2. Iniciar Chromium headless con remote debugging
```bash
proot-distro login ubuntu --shared-tmp -- /bin/bash -c '
    /root/.cache/ms-playwright/chromium-*/chrome-linux/chrome \
        --headless --no-sandbox --remote-debugging-port=9222 \
        --disable-gpu --disable-dev-shm-usage \
        http://localhost:8550 &
    sleep 3
'
```

### 3. Attach playwright-cli
```bash
playwright-cli attach --cdp=http://localhost:9222
```

### 4. Ejecutar comandos
```bash
playwright-cli snapshot
playwright-cli screenshot
playwright-cli eval "document.title"
```

### 5. Cerrar
```bash
playwright-cli close
# Matar Chromium
proot-distro login ubuntu --shared-tmp -- pkill -f chrome
```

### Con el wrapper `playwright-proot`
```bash
playwright-proot open http://localhost:8550
playwright-proot snapshot
playwright-proot screenshot
playwright-proot close
```

---

## 🏗️ Arquitectura

```
Termux (Host)
├── Servidor target (Flet, etc.) en localhost:8550
└── proot-distro ubuntu
    ├── Librerías glibc + system libs
    ├── Node.js v22 + @playwright/cli
    ├── Chromium headless (arm64) con --remote-debugging-port=9222
    └── playwright-cli attach via CDP

Comunicación:
  localhost:8550 → app target (host)
  localhost:9222 → Chromium DevTools (dentro de proot)
  playwright-cli attach --cdp=http://localhost:9222
```

### Network

`proot-distro --shared-tmp` comparte el network namespace del host. El contenedor Ubuntu puede acceder a `localhost:8550` (servidor Flet en Termux) y viceversa.

---

## ⚠️ Limitaciones y Troubleshooting

| Problema | Causa | Solución |
|----------|-------|----------|
| `chrome: error while loading shared libraries` | Librerías glibc faltantes dentro de Ubuntu | Ejecutar `apt install -y $LINUX_LIBS` |
| `ERROR:dbus/bus.cc` | No hay system D-Bus | No es fatal, ignorar |
| `ERROR:udev` | No hay udev | No es fatal, ignorar |
| Solo se ve botón "Enable accessibility" | Flet renderiza via CanvasKit (no DOM) | Usar `screenshot` + `snapshot` + `eval` |
| `Target closed` | Chromium crasheó | Reiniciar Chromium |
| `ECONNREFUSED localhost:9222` | Chromium no iniciado | Ejecutar `playwright-proot open` primero |

---

## 📋 Referencias

- [Adaptación de binarios glibc en Termux](./compilacion-glibc.md)
- [Repositorio del paquete playwright-proot](https://github.com/ivam3/termux-packages/tree/master/packages/playwright-proot)
- [Playwright CLI Docs](https://playwright.dev/docs/cli)
- [proot-distro](https://github.com/termux/proot-distro)
