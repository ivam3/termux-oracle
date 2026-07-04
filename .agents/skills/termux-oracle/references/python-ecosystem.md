# Python Ecosystem Reference

## Instalación base
```bash
pkg install python  # Instala Python + pip + setuptools + wheel
```

## Compilación de librerías complejas
Muchos paquetes Python no tienen wheels para ARM64 Android. Pip intenta compilar desde fuente y falla. Estructura de dependencias:

| Si instalas vía pip | Instala primero vía pkg |
|---------------------|------------------------|
| `cryptography` | `pkg install libffi openssl` |
| `lxml` | `pkg install libxml2 libxslt` |
| `Pillow` | `pkg install libjpeg-turbo libpng` |
| `numpy`/`scipy`/`pandas` | `pkg install fftw libandroid-support` |

Dependencias de compilación esenciales:
```bash
pkg install clang make python-aptsources libjpeg-turbo
```

## Paquetes Python precompilados (via apt)
Para evitar compilación lenta o fallida, existen versiones precompiladas:

### Repositorio stable (oficial Termux)
`python-apsw`, `python-apt`, `python-bcrypt`, `python-brotli`, `python-cmake`,
`python-contourpy`, `python-cryptography`, `python-ensurepip-wheels`, `python-greenlet`,
`python-grpcio`, `python-lameenc`, `python-libsass`, `python-llvmlite`, `python-lxml`,
`python-msgpack`, `python-numpy`, `python-numpy-static`, `python-onnxruntime`,
`python-pillow`, `python-psutil`, `python-pyarrow`, `python-pycryptodomex`,
`python-pynvim`, `python-pyppmd`, `python-ruff`, `python-sabyenc3`, `python-skia-pathops`,
`python-static`, `python-tflite-runtime`, `python-tkinter`, `python-tldp`,
`python-torch`, `python-torch-static`, `python-torchaudio`, `python-torchcodec`,
`python-torchvision`, `python-trash-cli`, `python-xcbgen`, `python-xlib`,
`python-yt-dlp`, `python2`, `python2-static`

### tur-repo (comunitario)
`python-cairo`, `python-fitsio`, `python-future`, `python-kivy`,
`python-mitmproxy-wireguard`, `python-opengl`, `python-pandas`, `python-polars`,
`python-pygame`, `python-pywavelets`, `python-scikit-image`, `python-scipy`,
`python-seledroid`, `python-tiktoken`, `python-tls-client`, `python-tokenizers`,
`python2-numpy`, `python2-scipy`
Versiones específicas: `python3.7`..`python3.11` con `-static`, `-tkinter`, `-cross`

### termux-x11 (gráficos)
`opencv-python`, `python-opencv-python`, `python-pyqtwebengine`, `python-qscintilla`, `python-xapp`

### glibc-repo (compatibilidad Linux)
`python-glibc`, `python-glibc-static`, `python-pip-glibc`, `python-py3c-glibc`, `python-xcbgen-glibc`

## Entornos virtuales
Siempre que sea posible, usar `venv`:
```bash
python -m venv venv
source venv/bin/activate
pip install <paquete>
```

## Error "externally-managed-environment"
En Python ≥3.11, pip bloquea instalaciones globales.
- Solución recomendada: usar `venv`
- Solución rápida (riesgosa): `pip install <paquete> --break-system-packages`
