# OBS Studio y cámaras USB/teléfono en Termux 🎥

Esta integración de **i-HakLab** permite usar la cámara de un teléfono Android y, opcionalmente, una cámara UVC por USB como fuentes locales de **OBS Studio** en Termux-X11. No requiere la app *USB Camera* ni hardware adicional.

> **Ruta recomendada:** `phone-cam` para la cámara del teléfono. La cámara USB (`cam-usb`) es opcional y depende de que el dispositivo UVC esté conectado.

La captura se publica como **MJPEG** en `127.0.0.1`:

| Fuente | Stream | Snapshot | Puerto |
| --- | --- | --- | --- |
| Cámara USB (UVC) | `http://127.0.0.1:9000/video` | `http://127.0.0.1:9000/snapshot` | 9000 |
| Cámara del teléfono | `http://127.0.0.1:9001/video` | `http://127.0.0.1:9001/snapshot` | 9001 |

## Instalación

Con i-HakLab, el wrapper `apt` ejecuta `preconf obs-studio` **antes** de instalar el paquete y `pkg2conf obs-studio` después:

```bash
apt install obs-studio
```

`preconf` instala las dependencias que falten y compila los helpers de cámara:

- `ffmpeg`, `scrcpy`, `android-tools`, `termux-api`, `mpv`
- `clang`, `cmake`, `make`, `pkg-config`
- `libusb`, `libjpeg-turbo`, `git`, `python`, `procps`, `coreutils`
- `libuvc` se clona en `~/.local/src/uvc-cam/libuvc`, fijado al tag `v0.0.9`

`pkg2conf` aplica la configuración descrita en [Configuración automática tras la instalación](#configuración-automática-tras-la-instalación-pkg2conf).

Si instalaste OBS sin el wrapper, ejecuta la configuración manualmente:

```bash
~/.local/libexec/preconf obs-studio
~/.local/libexec/pkg2conf obs-studio
```

## Configuración automática tras la instalación (`pkg2conf`)

`apt install obs-studio` ejecuta `pkg2conf obs-studio` al terminar. El proceso
es **idempotente**: repetirlo no duplica fuentes ni escenas y solo completa lo
que falte.

### Guardas antes de escribir

- **OBS abierto** (`pgrep -x obs`): no modifica nada. OBS mantiene la colección
  en memoria y la guardaría al salir, sobrescribiendo los cambios. Muestra un
  aviso y pide cerrar OBS y repetir `pkg2conf obs-studio`.
- **Sin `python3`**: no hace cambios (la fusión de JSON depende de Python).
- Si la fusión falla, avisa pero no revierte la instalación de OBS.

### Perfil, colección y lienzo

- Lee `~/.config/obs-studio/user.ini` y usa el perfil activo
  (`[Basic] ProfileDir`, por defecto `Termux`) y la colección activa
  (`[Basic] SceneCollectionFile`, por defecto `Untitled.json`).
- Si no existe `user.ini` y la colección tampoco, crea un `user.ini` mínimo con
  `Profile=Termux`, `ProfileDir=Termux`, `SceneCollection=Untitled` y
  `SceneCollectionFile=Untitled.json`.
- Toma la resolución del lienzo de
  `basic/profiles/<perfil>/basic.ini` → `[Video] BaseCX` / `BaseCY`
  (1920×1080 por defecto) y escala las fuentes a ese tamaño.
- Solo modifica **la colección activa**; no toca otras colecciones ni perfiles.

### Fuentes MJPEG creadas (2)

| Fuente | URL | Ajustes aplicados |
| --- | --- | --- |
| **Cámara USB (MJPEG)** | `http://127.0.0.1:9000/video` | `ffmpeg_source`, formato `mpjpeg` |
| **Cámara Teléfono (MJPEG)** | `http://127.0.0.1:9001/video` | `ffmpeg_source`, formato `mpjpeg` |

En ambas fuentes:

- `close_when_inactive` activado (libera el stream cuando la fuente no se ve).
- No son archivo local, no hay bucle y `clear_on_media_end` está desactivado.
- `hw_decode` desactivado (decodificación por software, más estable en Termux).
- Audio **silenciado**: el MJPEG no trae pista de audio y así se evitan errores.
- UUID determinista (`uuid5`): al repetir `pkg2conf` se reutiliza la misma
  fuente en lugar de crear duplicados.

Si la fuente ya existe con el tipo `ffmpeg_source`, actualiza URL, formato,
`close_when_inactive` y silencio. Si existe con **otro tipo**, la deja intacta y
avisa; solo reutiliza su UUID para las escenas.

### Escenas creadas (4)

| Escena | Contenido y geometría |
| --- | --- |
| **Cámara USB** | Fuente USB a pantalla completa. |
| **Cámara Trasera** | Fuente del teléfono a pantalla completa. |
| **Cámara Frontal** | Fuente del teléfono a pantalla completa. |
| **USB + Teléfono** | USB a pantalla completa + teléfono en PiP abajo a la derecha (25 % del ancho, margen de 40 px). |

- Solo crea las escenas que **no existan**; las del usuario se dejan intactas.
- Añade las nuevas al final de `scene_order` y rellena `current_scene` /
  `current_program_scene` solo si apuntan a una escena inexistente (en ese caso,
  **Cámara USB**).
- Las escenas **Cámara Trasera** y **Cámara Frontal** apuntan a la misma fuente
  MJPEG del teléfono (9001): el cambio real de cámara se hace con
  `phone-cam back` o `phone-cam front`, no cambiando de escena.
- Completa claves ausentes de la colección (transición `Fade` de 300 ms,
  `version: 2`, etc.) sin alterar las existentes.

### Backup y escritura atómica

- Si la colección ya existe, copia antes a
  `Untitled.json.bak.ih-AAAAMMDD-HHMMSS` (por ejemplo,
  `Untitled.json.bak.ih-20261108103000`). Los reintentos generan backups
  nuevos; no se sobrescribe el anterior.
- Escribe primero en un archivo `.tmp` y lo mueve con `os.replace()`, de modo
  que un corte no deja un JSON a medias.
- `pkg2conf` no inicia los streams ni empareja ADB: eso lo hacen `phone-cam` y
  `cam-usb`.

### Fallback de los helpers de cámara

Después de fusionar las escenas, si `~/.local/src/uvc-cam/uvc-stream` no es
ejecutable (por ejemplo, OBS se instaló con el `apt` nativo sin `preconf`),
`pkg2conf` lanza:

```bash
~/.local/libexec/i-Haklab/build-uvc-cam
```

El resultado se registra en el log de i-HakLab y, si falla, se puede repetir a
mano. Ver [Recompilar los helpers](#recompilar-los-helpers).

Para abrir OBS necesitas una sesión gráfica de Termux-X11:

```bash
termux-x11 :1 -xstartup "dbus-launch --exit-with-session xfce4-session" &
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity
DISPLAY=:1 obs
```

## Escenas creadas

| Escena | Contenido |
| --- | --- |
| **Cámara USB** | Cámara UVC a pantalla completa. |
| **Cámara Trasera** | Cámara trasera del teléfono a pantalla completa. |
| **Cámara Frontal** | Cámara frontal del teléfono a pantalla completa. |
| **USB + Teléfono** | USB a pantalla completa y teléfono en ventana PiP. |

Si las escenas no aparecen:

```bash
pkg2conf obs-studio
```

Cierra OBS antes de ejecutar `pkg2conf`; al salir, OBS guarda su colección y podría sobrescribir los cambios.

## Cámara del teléfono (recomendado)

Requiere depuración inalámbrica activa, un dispositivo ADB conectado y `scrcpy` 5.x. La guía de emparejamiento está en [Wireless Debugging](../../android/wireless-debugging.md).

```bash
adb devices
phone-cam --list       # cámaras disponibles
phone-cam back         # cámara trasera (id 0) en el puerto 9001
phone-cam front        # cámara frontal (id 1) en el puerto 9001
phone-cam 0 9001       # cámara por id y puerto explícitos
phone-cam --stop       # detiene scrcpy, ffmpeg y el servidor MJPEG
```

`phone-cam` usa `scrcpy --video-source=camera` sin ventana de previsualización, captura a 1280x720/30 fps y convierte el flujo a MJPEG. El log queda en `~/.cache/phone-cam/phone-cam.log`.

Verificación:

```bash
curl -fsS http://127.0.0.1:9001/snapshot -o /tmp/phone.jpg
```

La mayoría de los HAL de cámara no permiten abrir la frontal y la trasera a la vez. `phone-cam front` y `phone-cam back` se alternan; una cámara USB sí puede convivir con una cámara del teléfono.

## Cámara USB (opcional)

La app *USB Camera* (`com.shenyaocn.android.usbcamera`) **no es necesaria**. Si está instalada, ciérrala o deshabilítala para que no reclame el dispositivo UVC.

```bash
cam-usb --list       # lista dispositivos USB visibles
cam-usb --probe      # pide permiso y guarda VID:PID
cam-usb              # inicia el stream en el puerto 9000
cam-usb --stop       # detiene el stream
```

La primera vez Android muestra un diálogo de permiso USB. Acepta el acceso y repite `cam-usb --probe` si es necesario. El VID:PID se guarda en `~/.config/cam-usb.vidpid`.

Verificación:

```bash
curl -fsS http://127.0.0.1:9000/snapshot -o /tmp/usb.jpg
```

Si no hay cámara USB conectada, `termux-usb -l` puede devolver una lista vacía; eso es normal y no afecta a `phone-cam`.

## Añadir la fuente manualmente en OBS

Si no usas las escenas de i-HakLab, crea una **Fuente multimedia** (*Media Source*) y configura:

- **Local file:** desactivado.
- **Input/URL:** `http://127.0.0.1:9001/video` para el teléfono o `http://127.0.0.1:9000/video` para USB.
- **Input Format:** `mpjpeg` si OBS lo solicita.
- **Restart playback when source becomes active:** activado.

## Ventanas flotantes

```bash
cam-float                 # ventana flotante para la cámara USB
phone-float               # ventana flotante para la cámara del teléfono
cam-float --stop
phone-float --stop
```

Ambas ventanas usan `mpv` sin bordes, siempre encima, y se pueden mover con `cam-float 480x360+20+20`.

## Variables de entorno

| Variable | Valor por defecto | Uso |
| --- | --- | --- |
| `CAM_PORT` | `9000` | Puerto del stream USB. |
| `PHONE_CAM_PORT` | `9001` | Puerto del stream del teléfono. |

Ejemplo:

```bash
PHONE_CAM_PORT=9011 phone-cam back
```

## Recompilar los helpers

Si cambias el código o una actualización de libuvc falla:

```bash
~/.local/libexec/i-Haklab/build-uvc-cam
```

Los binarios quedan en `~/.local/src/uvc-cam/`: `uvc-stream`, `usbdesc` y `mjpeg-pipe-server`.

## Desinstalación

`apt remove obs-studio` ejecuta el caso `obs-studio` de `cleanup`:

- elimina solo las escenas y fuentes creadas por i-HakLab;
- conserva las escenas, fuentes y grupos del usuario;
- conserva una fuente de cámara si otra escena del usuario todavía la usa;
- elimina `libuvc` y los binarios generados por `preconf` en `~/.local/src/uvc-cam/`, pero mantiene el código fuente y los scripts;
- deja una copia `Untitled.json.bak.cleanup-<fecha>` antes de modificar OBS.

## Solución de problemas

- **`No USB devices are visible`**: conecta la cámara, revisa el diálogo de permiso USB y confirma con `termux-usb -l`.
- **La cámara USB está ocupada**: cierra o deshabilita la app *USB Camera*.
- **ADB en `offline`**: reconecta la depuración inalámbrica y vuelve a probar `adb devices`; `phone-cam` prefiere un serial `IP:puerto` cuando hay varios.
- **OBS está abierto al ejecutar `pkg2conf`**: ciérralo y ejecuta `pkg2conf obs-studio`.
- **`curl` no responde**: comprueba el puerto (`9000` USB, `9001` teléfono), el log `~/.cache/phone-cam/phone-cam.log` y que el proceso siga vivo.
- **La cámara frontal no abre**: cambia a `phone-cam back`; algunos HAL no permiten simultaneidad.
- **No aparece la escena**: ejecuta `pkg2conf obs-studio` y vuelve a abrir OBS.

## Sin i-HakLab

Sin la suite, la vía más simple es instalar las dependencias y usar `phone-cam`/`cam-usb` desde el repositorio de i-HakLab:

```bash
pkg install x11-repo
pkg install obs-studio ffmpeg scrcpy android-tools termux-api mpv
pkg install clang cmake make pkg-config libusb libjpeg-turbo git python
```

Después hay que replicar los helpers `uvc-stream`, `usbdesc` y `mjpeg-pipe-server` desde `~/.local/src/uvc-cam/` y añadir la URL MJPEG como fuente multimedia en OBS. La fusión automática de escenas, los wrappers y la limpieza son específicos de i-HakLab.
