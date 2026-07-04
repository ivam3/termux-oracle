# Configuración del Entorno Python en Termux 🐍💻

**Python** es el lenguaje de programación más utilizado en ciberseguridad, scripting y automatización dentro del ecosistema Termux. Esta guía te enseñará cómo configurar un entorno Python estable, instalar paquetes de forma correcta y solucionar errores comunes de compilación al usar `pip`.

---

## 🛠️ 1. Instalación de Python y Pip

Para instalar Python y el gestor de paquetes `pip` en Termux, ejecuta:

```bash
pkg update
pkg install python -y
```

Este comando instala la última versión estable de Python, `pip`, y las herramientas estándar de empaquetado (`setuptools` y `wheel`).

* **Verificar instalación**:
  ```bash
  python --version
  pip --version
  ```

---

## 🏗️ 2. Compilación de Librerías Complejas (El entorno de desarrollo C/C++)

Muchos paquetes populares de Python (como `cryptography`, `pillow`, `numpy` o `lxml`) no proveen binarios precompilados (*wheels*) para la arquitectura ARM/ARM64 de Android. Cuando ejecutas `pip install <paquete>`, pip intentará compilar el código fuente en C/C++ localmente.

Si no tienes instaladas las herramientas de compilación del sistema, el comando fallará con errores del tipo `Failed building wheel` o `command 'clang' failed`.

### Instalación de dependencias de desarrollo esenciales:
Antes de instalar librerías complejas, debes preparar el compilador ejecutando:
```bash
pkg install clang make python-aptsources libjpeg-turbo -y
```

### Tabla de Dependencias Comunes:

| Si deseas instalar (vía pip) | Debes instalar primero en Termux (vía pkg) |
| :--- | :--- |
| **`cryptography` / `paramiko`** | `pkg install libffi openssl` |
| **`lxml` / `beautifulsoup4`** | `pkg install libxml2 libxslt` |
| **`Pillow`** (manipulación de imágenes) | `pkg install libjpeg-turbo libpng` |
| **`numpy` / `scipy` / `pandas`** | `pkg install fftw libandroid-support ndk-sysroot` |

> [!TIP]
> Si una instalación de pip sigue fallando, lee con atención las últimas líneas del log de error. Usualmente te dirá que falta un archivo de cabecera `.h` (ej. `openssl/ssl.h`). Eso significa que debes buscar el paquete del sistema correspondiente (ej. `openssl`) e instalarlo mediante `pkg install`.

---

## 📦 3. Entornos Virtuales (`venv`)

Es una buena práctica crear entornos virtuales independientes para tus proyectos de desarrollo en Termux para evitar conflictos entre versiones de paquetes globales.

### Creación y activación de un entorno virtual:
1. Navega a la carpeta de tu proyecto:
   ```bash
   cd ~/mi_proyecto
   ```
2. Crea el entorno virtual (llamado `venv`):
   ```bash
   python -m venv venv
   ```
3. Activa el entorno virtual:
   ```bash
   source venv/bin/activate
   ```
   *(Verás que el prompt de la terminal ahora tiene un prefijo `(venv)`).*
4. Para salir del entorno virtual en cualquier momento, ejecuta:
   ```bash
   deactivate
   ```

---

## ⚠️ 4. Solución de Errores Frecuentes

### Error: "externally-managed-environment" al usar pip
En versiones recientes de Python (a partir de 3.11/3.12), por razones de estabilidad del sistema operativo, el gestor de paquetes de Termux puede bloquear el uso de `pip install` a nivel global.
* **Solución recomendada**: Utiliza siempre un entorno virtual (`venv`) como se describe en el punto anterior.
* **Solución rápida (uso global)**: Si necesitas instalar un paquete a nivel global y bajo tu propio riesgo, puedes forzar la instalación agregando el parámetro `--break-system-packages`:
  ```bash
  pip install <nombre_paquete> --break-system-packages
  ```

### Error: `numpy` o `pandas` no compila
Instalar librerías de ciencia de datos desde el código fuente puede demorar horas en el procesador de un celular o fallar por incompatibilidades.
* **Solución**: En lugar de usar `pip`, puedes instalar versiones precompiladas de estas librerías directamente desde los repositorios de Termux:
  ```bash
  pkg install python-numpy python-pandas -y
  ```
* **Repositorios adicionales (tur-repo)**: Si necesitas paquetes científicos avanzados, puedes habilitar el repositorio comunitario de Termux User Repository:
  ```bash
  pkg install tur-repo -y
  pkg update
  ```

> Para una lista completa de paquetes Python precompilados disponibles en los distintos repositorios de Termux, consulta la sección **[📦 Paquetes Python Precompilados](paquetes.md#-6-paquetes-python-precompilados-para-android-vía-aptpkg)** en la guía de gestión de paquetes.
