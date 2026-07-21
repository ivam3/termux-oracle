# Playwright CLI en Termux via proot-distro Ubuntu

Chromium requiere ~31 librerías glibc (GTK, X11, NSS, D-Bus) que no existen en Termux nativo. Se usa proot-distro Ubuntu como contenedor glibc completo.

## Instalación via .deb (recomendado)
```bash
apt install playwright-proot
```
El `postinst` automatiza: proot-distro Ubuntu + librerías glibc + Node.js 22 + `@playwright/cli` + Chromium.

## Instalación manual
```bash
proot-distro install ubuntu
proot-distro login ubuntu --shared-tmp -- /bin/bash -c '
    apt update && apt install -y libglib2.0-0t64 libnss3 libnspr4 \
        libdbus-1-3 libatk1.0-0t64 libatk-bridge2.0-0t64 libcups2t64 \
        libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 \
        libxrandr2 libgbm1 libpango-1.0-0 libcairo2 libasound2t64 \
        libatspi2.0-0t64 libudev1
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
    apt install -y nodejs
    npm install -g @playwright/cli@latest
    playwright-cli install-browser chromium
'
```

## Uso
```bash
# 1. Iniciar app target en Termux (host)
flet run --web --port 8550 main.py

# 2. Iniciar Chromium headless
proot-distro login ubuntu --shared-tmp -- /bin/bash -c '
    /root/.cache/ms-playwright/chromium-*/chrome-linux/chrome \
        --headless --no-sandbox --remote-debugging-port=9222 \
        --disable-gpu --disable-dev-shm-usage \
        http://localhost:8550 &
    sleep 3
'

# 3. Attach playwright-cli
playwright-cli attach --cdp=http://localhost:9222

# 4. Comandos
playwright-cli snapshot
playwright-cli screenshot
playwright-cli eval "document.title"

# 5. Cerrar
playwright-cli close
proot-distro login ubuntu --shared-tmp -- pkill -f chrome
```

## Con el wrapper `playwright-proot`
```bash
playwright-proot open http://localhost:8550
playwright-proot snapshot
playwright-proot screenshot
playwright-proot close
```

## Troubleshooting
| Problema | Solución |
|----------|----------|
| `chrome: error while loading shared libraries` | `apt install -y $LINUX_LIBS` en Ubuntu |
| Solo se ve botón "Enable accessibility" | CanvasKit (no DOM), usar `screenshot`/`snapshot`/`eval` |
| `Target closed` | Reiniciar Chromium |
| `ECONNREFUSED localhost:9222` | Ejecutar `playwright-proot open` primero |
