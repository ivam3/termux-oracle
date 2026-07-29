# Playwright-cli para Termux via proroot (Ubuntu 24.04) 🎭

Este documento describe la arquitectura y método para ejecutar **Playwright CLI** (automatización de navegador) en Termux/Android utilizando **proroot** como runtime Linux rootless con rendimiento casi nativo.

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

En Termux nativo (Bionic libc) varias de estas librerías no existen en los repos glibc, y además se necesitan servicios del sistema (D-Bus, udev) que Android no provee.

---

## 🛠️ La Solución: proroot

**proroot** reemplaza `proot-distro ubuntu` como runtime del contenedor. A diferencia de proot (que usa ptrace con overhead por syscall), proroot usa LD_PRELOAD + parcheo ELF — eliminando los cambios de contexto y ofreciendo rendimiento casi nativo para Chromium.

Ventajas sobre proot-distro:
- ✅ Mismo rootfs Ubuntu 24.04 con glibc completo
- ✅ Misma resolución de dependencias via `apt`
- ✅ Network namespace compartido (localhost directo al host)
- ✅ **Sin overhead de ptrace** — Chromium corre hasta 3-5x más rápido
- ✅ Menor latencia en Node.js y comunicación CDP

### Limitación conocida

El "Enable accessibility" button de Flet/Flutter es el único elemento en el árbol de accesibilidad. Los elementos renderizados por CanvasKit no son accesibles como DOM nodes. Para testing funcional, usar `screenshot` + `snapshot` + `eval` en lugar de `click`.

---

## 📦 Instalación

### Via paquete .deb (recomendado)

```bash
apt install playwright-proot
```

El `postinst` automatiza:
1. Verifica que proroot esté instalado (dependencia automática)
2. `apt install -y libglib2.0-0t64 libnss3 libnspr4 libdbus-1-3 libatk1.0-0t64 libatk-bridge2.0-0t64 libcups2t64 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libgbm1 libpango-1.0-0 libcairo2 libasound2t64 libatspi2.0-0t64 libudev1` dentro del rootfs proroot
3. `curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && apt install -y nodejs`
4. `npm install -g @playwright/cli@latest`
5. `playwright-cli install-browser chromium`

### Manual

```bash
# 1. Asegurar que proroot está instalado y tiene rootfs
pkg install proroot

# 2. Librerías del sistema
proroot /bin/bash -c '
    apt update && apt install -y libglib2.0-0t64 libnss3 libnspr4 \
        libdbus-1-3 libatk1.0-0t64 libatk-bridge2.0-0t64 libcups2t64 \
        libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 \
        libxrandr2 libgbm1 libpango-1.0-0 libcairo2 libasound2t64 \
        libatspi2.0-0t64 libudev1
'

# 3. Node.js + playwright-cli + Chromium
proroot /bin/bash -c '
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
proroot /bin/bash -c '
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
proroot /bin/bash -c 'pkill -f chrome'
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
└── proroot (Ubuntu 24.04, sin ptrace)
    ├── Librerías glibc + system libs
    ├── Node.js v22 + @playwright/cli
    ├── Chromium headless (arm64) con --remote-debugging-port=9222
    └── playwright-cli attach via CDP

Comunicación:
  localhost:8550 → app target (host)
  localhost:9222 → Chromium DevTools (dentro de proroot)
  playwright-cli attach --cdp=http://localhost:9222
```

### Network

proroot comparte el network namespace del host al igual que proot. El contenedor puede acceder a `localhost:8550` (servidor Flet en Termux) y viceversa.

---

## ⚠️ Limitaciones y Troubleshooting

| Problema | Causa | Solución |
|----------|-------|----------|
| `chrome: error while loading shared libraries` | Librerías glibc faltantes dentro de Ubuntu | Ejecutar `proroot /bin/bash -c "apt install -y \$LINUX_LIBS"` |
| `ERROR:dbus/bus.cc` | No hay system D-Bus | No es fatal, ignorar |
| `ERROR:udev` | No hay udev | No es fatal, ignorar |
| Solo se ve botón "Enable accessibility" | Flet renderiza via CanvasKit (no DOM) | Usar `screenshot` + `snapshot` + `eval` |
| `Target closed` | Chromium crasheó | Reiniciar Chromium |
| `ECONNREFUSED localhost:9222` | Chromium no iniciado | Ejecutar `playwright-proot open` primero |
| `proroot: command not found` | proroot no instalado | `pkg install proroot` |

---

## 📋 Referencias

- [Adaptación de binarios glibc en Termux](./compilacion-glibc.md)
- [Documentación de proroot](./proroot.md)
- [Repositorio del paquete playwright-proot](https://github.com/ivam3/termux-packages/tree/master/packages/playwright-proot)
- [Playwright CLI Docs](https://playwright.dev/docs/cli)
- [proroot — Rootless Linux runtime](../recursos/herramientas/proroot.md)
