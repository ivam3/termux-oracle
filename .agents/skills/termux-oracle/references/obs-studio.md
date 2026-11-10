# OBS Studio y cámaras en Termux (i-HakLab)

> **Validar primero:** `bash ~/.agents/skills/termux-oracle/scripts/detect-env.sh`. Si `ihaklab_installed=false`, no asumir `phone-cam`, `cam-usb`, `pkg2conf` ni `preconf`; ver "Sin i-HakLab" al final.

Integración de i-HakLab para publicar la cámara del teléfono y, opcionalmente, una cámara UVC por USB como MJPEG local para OBS Studio. **No requiere** la app `com.shenyaocn.android.usbcamera`.

## Streams

| Fuente | Video | Snapshot | Puerto |
|---|---|---|---|
| Teléfono | `http://127.0.0.1:9001/video` | `/snapshot` | 9001 |
| USB UVC | `http://127.0.0.1:9000/video` | `/snapshot` | 9000 |

## Instalación rápida (i-HakLab)

```bash
apt install obs-studio
```

El wrapper `apt` ejecuta `preconf obs-studio` antes de instalar y `pkg2conf obs-studio` después. `preconf` instala `ffmpeg`, `scrcpy`, `android-tools`, `termux-api`, `mpv`, `clang`, `cmake`, `make`, `pkg-config`, `libusb`, `libjpeg-turbo`, `git`, `python`, `procps`, `coreutils`, y compila los helpers con `libuvc` fijado a `v0.0.9`.

Si hace falta repetir la configuración:

```bash
~/.local/libexec/preconf obs-studio
~/.local/libexec/pkg2conf obs-studio
```

Cerrar OBS antes de `pkg2conf`; OBS guarda la colección al salir. El comando crea un backup `Untitled.json.bak.ih-<fecha>` y no borra escenas del usuario.

Escenas: **Cámara USB**, **Cámara Trasera**, **Cámara Frontal**, **USB + Teléfono** (USB principal + teléfono en PiP).

### Qué configura `pkg2conf` tras instalar

1. **Guardas:** si OBS está abierto (`pgrep -x obs`) o falta `python3`, no escribe nada y avisa; repetir tras cerrar OBS.
2. **Perfil/colección activos:** lee `~/.config/obs-studio/user.ini` (`ProfileDir`, `SceneCollectionFile`) y la resolución de `basic.ini` (`BaseCX`/`BaseCY`, 1920×1080 por defecto). Solo toca la colección activa.
3. **2 fuentes** `ffmpeg_source` con formato `mpjpeg`: *Cámara USB (MJPEG)* → `:9000/video` y *Cámara Teléfono (MJPEG)* → `:9001/video`; `close_when_inactive`, sin audio (silenciadas), UUID determinista y actualización idempotente.
4. **4 escenas** (solo crea las que falten): **Cámara USB**, **Cámara Trasera**, **Cámara Frontal** y **USB + Teléfono** (USB a pantalla completa + teléfono PiP al 25 % abajo a la derecha). Trasera/Frontal comparten la fuente del teléfono; el cambio se hace con `phone-cam`.
5. **Backup** `Untitled.json.bak.ih-AAAAMMDD-HHMMSS` y escritura atómica vía `.tmp` + `os.replace()`.
6. **Fallback:** si falta `~/.local/src/uvc-cam/uvc-stream`, ejecuta `build-uvc-cam` (caso de instalación con apt nativo).

No inicia streams, no empareja ADB ni concede permiso USB: eso es `phone-cam`/`cam-usb`.

## Cámara del teléfono (recomendado)

Requisitos: ADB conectado (vale depuración inalámbrica; ver `references/android-limitations.md` y `docs/android/wireless-debugging.md`), `scrcpy` 5.x.

```bash
adb devices
phone-cam --list
phone-cam back          # id 0, puerto 9001
phone-cam front         # id 1, puerto 9001
phone-cam <id> [puerto]
phone-cam --stop
curl -fsS http://127.0.0.1:9001/snapshot -o /tmp/phone.jpg
```

`phone-cam` usa `scrcpy --video-source=camera` sin ventana, 1280x720/30 fps, y `ffmpeg` → `mjpeg-pipe-server`. Log: `~/.cache/phone-cam/phone-cam.log`. El puerto se puede cambiar con `PHONE_CAM_PORT`.

La cámara frontal y la trasera normalmente no pueden abrirse a la vez. Una cámara USB sí puede convivir con una del teléfono.

## Cámara USB (opcional)

Cerrar o deshabilitar la app *USB Camera* si está instalada; no es necesaria.

```bash
cam-usb --list
cam-usb --probe         # solicita permiso USB y guarda VID:PID
cam-usb                 # puerto 9000
cam-usb --stop
curl -fsS http://127.0.0.1:9000/snapshot -o /tmp/usb.jpg
```

VID:PID en `~/.config/cam-usb.vidpid`. Puerto configurable con `CAM_PORT`. Si no hay cámara conectada, `termux-usb -l` puede devolver `[]`; no afecta a `phone-cam`.

## OBS manual

Añadir una **Fuente multimedia / Media Source**:

- Local file: desactivado.
- Input/URL: `http://127.0.0.1:9001/video` (teléfono) o `http://127.0.0.1:9000/video` (USB).
- Input Format: `mpjpeg` si se solicita.
- Restart playback when source becomes active: activado.

## Ventanas flotantes

```bash
cam-float
phone-float
cam-float --stop
phone-float --stop
```

Usan `mpv` sin bordes y siempre encima; aceptan geometría, por ejemplo `cam-float 480x360+20+20`.

## Recompilar y limpiar

```bash
~/.local/libexec/i-Haklab/build-uvc-cam
```

Los binarios quedan en `~/.local/src/uvc-cam/` (`uvc-stream`, `usbdesc`, `mjpeg-pipe-server`).

`apt remove obs-studio` ejecuta `cleanup obs-studio`: elimina solo escenas/fuentes creadas por i-HakLab, conserva las del usuario y las fuentes aún referenciadas, borra libuvc y binarios compilados, y deja `Untitled.json.bak.cleanup-<fecha>`.

## Troubleshooting

- `No USB devices are visible`: revisar cable, permiso USB y `termux-usb -l`.
- Cámara USB ocupada: cerrar/deshabilitar *USB Camera*.
- ADB `offline`: reconectar depuración inalámbrica; `phone-cam` prefiere seriales `IP:puerto`.
- OBS abierto al ejecutar `pkg2conf`: cerrarlo y repetir.
- `curl` sin respuesta: comprobar puerto, proceso y `~/.cache/phone-cam/phone-cam.log`.
- Sin escenas: `pkg2conf obs-studio` y reabrir OBS.

## Sin i-HakLab

```bash
pkg install x11-repo
pkg install obs-studio ffmpeg scrcpy android-tools termux-api mpv
pkg install clang cmake make pkg-config libusb libjpeg-turbo git python
```

Hay que replicar los helpers de `~/.local/src/uvc-cam/` y añadir la URL MJPEG como fuente multimedia. La fusión de escenas, los wrappers y la limpieza automática son específicos de i-HakLab.

Documentación completa: `docs/recursos/herramientas/obs-studio.md`.
