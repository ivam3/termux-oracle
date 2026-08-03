# yt-dlp

## ¿Qué es yt-dlp?

**yt-dlp** es un descargador de video de línea de comandos, **fork activo de `youtube-dl`**, que soporta YouTube y miles de otros sitios, incluyendo videos, audio y listas de reproducción. Es el motor de descarga recomendado en Termux e i-Haklab (reemplaza a la antigua herramienta `youtubedr`).

## ¿Para qué es útil?

* Descarga de videos educativos
* Extracción de audio
* Automatización de descargas
* Uso offline de contenido

## Instalación

En Termux se instala con el paquete `python-yt-dlp`:

```bash
pkg install python-yt-dlp
```

Para descargar formatos de alta calidad y fusionar video+audio se requieren además:

```bash
pkg install deno ffmpeg
```

* `deno`: runtime JS que yt-dlp usa para resolver el *JS challenge* de YouTube y exponer los formatos DASH de alta resolución (sin él solo obtiene ~360p).
* `ffmpeg`: fusiona los flujos de video y audio descargados por separado en un solo archivo.

## Ejemplos de uso

**Descargar un video:**

```bash
yt-dlp https://youtube.com/watch?v=XXXX
```

**Descargar solo audio:**

```bash
yt-dlp -x https://youtube.com/watch?v=XXXX
```

**Seleccionar calidad hasta 720p fusionando video+audio:**

```bash
yt-dlp -f "bv*+ba/b" -S "res:720" --merge-output-format mp4 URL
```

> **Nota sobre shorts/videos verticales:** el filtro `bestvideo[height<=720]` excluye la resolución 720p real en videos verticales (donde "720p" es 720×1280). Usar `-S res:X` para seleccionar por resolución independientemente de la orientación.

## Integración con i-Haklab

En la suite i-Haklab, `yt-dlp` sustituyó a la herramienta `youtubedr`. El paquete `yt-dlp` está registrado en `listofpkg2conf` y su configuración post-instalación (en `pkg2conf`) genera:

* `~/.netrc` — plantilla de credenciales por extractor.
* `/data/data/com.termux/files/usr/bin/termux-url-opener` — script que intercepta URLs compartidas a Termux desde Android y permite elegir formato (audio / 360p / 480p / 720p / 1080p), descargando a `~/storage/shared/Youtube/`.

El comando `i-Haklab show tutorials` usa `yt-dlp` (vía `chk-pkg yt-dlp python-yt-dlp`) para descargar tutoriales de la suite.

## Consideraciones legales

Respeta los términos de servicio de YouTube
Úsalo solo para contenido permitido
Evita redistribución no autorizada
