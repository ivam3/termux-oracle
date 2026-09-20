# telegram-desktop

Cliente oficial de Telegram para escritorio, empaquetado en el repo `x11` de Termux (`telegram-desktop`, Qt6). Corre bajo Termux-X11 con XFCE.

> No confundir con [`telegram`](./telegram.md) (abre la app Android vía `am start`), [`botgram`](./botgram.md) (scrapper CLI) ni [`walkie-tg`](./walkie-tg.md) (puente Walkie ↔ Telegram).

## Instalación y apertura

```bash
pkg install telegram-desktop   # instalacion individual (hace update implicito)
```

Con i-HakLab, el wrapper `apt` dispara `pkg2conf telegram-desktop` solo (dependencia WebKit + symlinks SONAME + lanzador + `.desktop`; ver § Integración i-Haklab). Sin i-HakLab, replicar § Fix manual.

Abrir siempre desde el **menú Whisker** (`Exec=telegram-desktop-x11`), nunca con el binario pelado si se quiere el lanzador estable. Tras instalar/actualizar/reinstalar: **cerrar Telegram por completo y reabrir** (los subprocesos WebView heredan inconsistencia si el binario cambia bajo un proceso vivo).

```bash
telegram-desktop-x11 -- %U   # lanzador estable (~/.local/bin), entorno stock
```

## Mini-apps (Bot WebApps)

Los bots exponen mini-apps (botón menú, botón `web_app` inline). Referencia de prueba: la mini-app de @BotFather debe abrir y ser interactiva. Si una mini-app pesada (Flet/Flutter, WebGL, WASM) queda en negro sobre llvmpipe, no es fallo del cliente: exponer una ruta HTML ligera con `Telegram.WebApp.openLink()` hacia el contenido pesado (patrón `/botapp`).

## Caso resuelto (sept-2026): de `~/tmp/out.txt` a `webview crashed`

### Síntoma 1 — mini-apps no abren, aparece `~/tmp/out.txt`

Texto del diálogo + `WebView Error: No library` en `~/.local/share/TelegramDesktop/log.txt`.

**Causas verificadas:**

1. El paquete no declara `webkit2gtk` como dependencia.
2. Termux sirve WebKitGTK **sin SONAME versionado** (`libwebkit2gtk-4.1.so`), pero el binario hace `dlopen` en orden `libwebkitgtk-6.0.so.4` → `libwebkit2gtk-4.1.so.0` → `libwebkit2gtk-4.0.so.37` (confirmado por `strings $PREFIX/bin/Telegram` + `WebView Error: No library` en log + `python3 ctypes.CDLL` fallando).

**Fix manual (sin i-HakLab):**

```bash
pkg install webkit2gtk-4.1
ln -sf libwebkit2gtk-4.1.so        $PREFIX/lib/libwebkit2gtk-4.1.so.0
ln -sf libjavascriptcoregtk-4.1.so $PREFIX/lib/libjavascriptcoregtk-4.1.so.0
ln -sf libwebkitgtk-6.0.so         $PREFIX/lib/libwebkitgtk-6.0.so.4
ln -sf libjavascriptcoregtk-6.0.so $PREFIX/lib/libjavascriptcoregtk-6.0.so.6
python3 -c "import ctypes; ctypes.CDLL('libwebkit2gtk-4.1.so.0'); print('DLOPEN OK')"
```

### Síntoma 2 — `webview crashed` en todas las mini-apps (incluso BotFather)

**Causas verificadas, en orden:**

1. **Reinstall con instancia viva** (visto en `$PREFIX/var/log/apt/history.log`): el binario/libs cambian bajo el proceso → los helpers nacen inconsistentes. Fix: cerrar del todo + relanzar.
2. **Variables de entorno contraproducentes**: con mesa ≥26.2.3, `WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS=1`, `WEBKIT_DISABLE_DMABUF_RENDERER=1`, `WEBKIT_DISABLE_COMPOSITING_MODE=1`, `GDK_BACKEND`, `QT_QPA_PLATFORM` extra **causan** el crash. Control: proceso fresco + entorno stock = todo OK. El lanzador queda pelado a `exec Telegram` (punto estable + hook futuro, sin vars).

### Arquitectura del WebView (para diagnosticar)

*   El WebView **no** es el proceso principal: es el subproceso `Telegram -webviewhelper <socket-tmp>` + `WebKitNetworkProcess` + `WebKitWebProcess` (`$PREFIX/libexec/webkit2gtk-4.1/`).
*   El `log.txt` de Telegram **no** registra el crash del helper. Inspección:
    ```bash
    pgrep -af "[T]elegram -webviewhelper"   # corchetes: pgrep -f se automachea
    grep -i webkit /proc/<pid-helper>/maps  # confirma 4.1 vs 6.0 cargado
    ```
*   `strace -f -e trace=process` reporta la muerte de **hilos** (`CLONE_THREAD`) como `killed by` — no confundir N líneas con N procesos.
*   No hay `bubblewrap`/`xdg-dbus-proxy` en repos Termux; con el fix actual no hacen falta.
*   Telegram aborta sin `DBUS_SESSION_BUS_ADDRESS` válido: relanzar siempre con el bus de la sesión XFCE viva (`/proc/<xfce4-session>/environ`).

## Límites conocidos (llvmpipe, no bugs de la app)

*   Firefox en Termux: `RenderCompositorSWGL failed mapping default framebuffer` + SIGSEGV con la carga CanvasKit+Pyodide (12 GB RAM descartan OOM; WebGL simple sí va). Conclusión: Flet/Flutter pesado inviable sobre llvmpipe.
*   MiniBrowser (`$PREFIX/libexec/webkit2gtk-4.1/MiniBrowser`) abre `example.com` y `web.telegram.org` sin errores: motor sano; el crash vive en la integración/contenido, no en WebKit base.

## Integración i-Haklab

*   `Tools/listofpkg2conf` registra `telegram-desktop` → el wrapper `apt` dispara la rama vía `ih_pkg2conf` (solo `pkg2conf`; `preconf` **nunca** corre en la ruta `apt`, solo en `npm`/`pnpm`).
*   Rama `telegram-desktop)` en `.local/libexec/pkg2conf`: guarda `dpkg -s webkit2gtk-4.1` → auto-instala si falta; 4 symlinks idempotentes; `curl $iHDB` del lanzador + `.desktop` (saltan si existen); `update-desktop-database`; limpia `~/tmp/out.txt`. Probada idempotente (2× exit 0) y auto-aplicada en un `reinstall` real.
*   `manifest.json` mapea `bin/telegram-desktop-x11` y el Readme; los `.desktop` **no** van en manifest por convención (cero precedentes) → se despliegan por `curl` en la rama.
*   Readme de usuario en `Tools/Readme/telegram-desktop.md` (tono uso, sin tecnicismos — el detalle vive aquí).

## Troubleshooting

| Problema | Causa / Solución |
|----------|------------------|
| Diálogo `install WebKitGTK` / `~/tmp/out.txt` / `WebView Error: No library` | Faltan symlinks SONAME o webkit → `pkg2conf telegram-desktop` (o fix manual §1) |
| `webview crashed` en todas, incluso BotFather | Cerrar del todo + reabrir (¿reinstall reciente con app viva?); verificar entorno stock (`grep -c WEBKIT /proc/<pid>/environ` → 0); no añadir vars |
| Mini-app Flet pesada en negro (sin crash) | Límite llvmpipe, no bug → ruta HTML ligera + `openLink` |
| Tras `reinstall`/`upgrade` (telegram, mesa, vulkan, webkit) | Reinicio completo obligatorio antes de diagnosticar |
| `apt` no aplica la configuración | Verificar `^telegram-desktop$` en `Tools/listofpkg2conf` (condición de `ih_pkg2conf`) |

## Sin i-HakLab

Replicable tal cual: `pkg install webkit2gtk-4.1`, los 4 `ln -sf`, lanzador `exec $PREFIX/bin/Telegram -- "$@"`, override `.desktop` con ese `Exec`, `update-desktop-database`. Sin wrappers: usar `pkg`/`apt`/`dpkg` nativos y los pasos manuales de §1. El `PATH` debe resolver `telegram-desktop-x11` (`~/.local/bin` delante).
