# Variables de Entorno y Configuración de API Keys en i-HakLab ⚙️🔑

El comportamiento, compilación y acceso a los servicios de inteligencia artificial de la suite **i-HakLab** están regulados por un conjunto de variables de entorno globales y un gestor interactivo de claves de API. 

Este documento detalla la estructura del archivo `envvariables` y el funcionamiento del comando `setapikey`.

---

## ⚙️ 1. Configuración del Entorno: El archivo `envvariables`

El archivo de configuración de variables se encuentra ubicado en:
`~/.local/etc/i-Haklab/envvariables`

Este script es cargado por la shell en cada inicio de sesión y define parámetros críticos de compilación, rutas de ejecutables y comportamiento de los servicios gráficos:

### 🔹 Variables del Entorno del Sistema

* **`export PATH="$HOME/.local/bin:/data/data/com.termux/files/usr/bin:$HOME/go/bin"`**:
  > [!IMPORTANT]
  > Inyecta el directorio local de ejecutables de la suite (`~/.local/bin/`) al **principio del PATH**. Esto garantiza que los wrappers e interceptores invisibles (como `apt` y `npm` locales) se ejecuten primero que los binarios nativos del sistema de Termux.
* **`export DISPLAY=:0`**: Configura el display gráfico por defecto para redireccionar la visualización de servidores X11/Xwayland nativos (usados por `termux-desktop-xfce`).
* **`export GYP_DEFINES="android_ndk_path=''"`**: Omite la comprobación estricta de rutas de compilación NDK durante la instalación global de módulos Node.js mediante npm (evita errores con `node-gyp`).
* **`export TOOLS=$HOME/.local/share`**: Define la ruta donde se alojan herramientas compartidas y submódulos (como PEDA para GDB).
* **`export JAVA_HOME=/data/data/com.termux/files/usr/opt/openjdk`**: Ruta base del JDK para el compilado de binarios Java y descompilación con Apktool/Apksigner.
* **`export ANDROID_NDK_HOME=/data/data/com.termux/files/usr`** y **`export ANDROID_API_LEVEL=24`**: Definen los directorios de cabeceras de desarrollo de Android para compilaciones cruzadas.
* **`export CFLAGS=" -Wno-incompatible-function-pointer-types"`**: Desactiva advertencias de compilación estrictas para permitir compilar proyectos de C antiguos usando clang moderno en Android.
* **`export CC=clang`** y **`export CXX=clang++`**: Establece a Clang/LLVM como los compiladores nativos del entorno.
* **`export VSCODE_EXTENSIONS_DIR=$HOME/.local/share/code-server/extensions`**: Directorio donde se almacenan y aíslan las extensiones instaladas en el servidor web de desarrollo VS Code (`code-server`).

### 🔹 Aliases Útiles Configurados

El archivo define atajos de consola para simplificar la navegación y la visualización:
* **`la`**: `ls -a` (listar todo, incluyendo ocultos).
* **`ll`**: `ls -l` (listado en formato largo).
* **`du`**: `du -hP` (uso de disco con rutas absolutas legibles).
* **`df`**: `duf` (despliegue estético y coloreado de almacenamiento).
* **`bat`**: `bat -f --theme 'Visual Studio Dark+'` (visor de archivos con sintaxis coloreada por defecto).
* **`postgresql`**: `pg_ctl -D /data/data/com.termux/files/usr/var/lib/postgresql` (control simplificado de la base de datos).

---

## 🔑 2. Gestión Centralizada de Claves: El Comando `setapikey`

Varios módulos interactivos de la suite (como `chatAI` para asistencia conversacional de IA o `phonescan` para recolección de telemetría de números telefónicos OSINT) requieren claves de acceso de APIs externas para funcionar.

El comando interactivo de control es:
```bash
i-Haklab setapikey
```

### 🔹 Plataformas Soportadas & Dónde Obtenerlas

Al ejecutar el comando, se mostrará un banner con enlaces directos para adquirir las llaves y un menú interactivo (`select`) para configurar los siguientes servicios:

1. **`chatGPT`** (OpenAI):
   * *Propósito*: Motor conversacional principal de IA.
   * *Obtención*: `https://platform.openai.com/account/api-keys`
2. **`claude`** (Anthropic):
   * *Propósito*: Asistencia de programación avanzada.
   * *Obtención*: `https://platform.claude.com/docs/en/api/admin/api_keys/retrieve`
3. **`deepseek`**:
   * *Propósito*: Consultas de modelos de IA de alta velocidad.
   * *Obtención*: `https://api-docs.deepseek.com/`
4. **`gemini`** (Google):
   * *Propósito*: Razonamiento de desarrollo asistido.
   * *Obtención*: `https://aistudio.google.com`
5. **`mistralAI`**:
   * *Propósito*: Procesamiento de lenguaje de código abierto de alto rendimiento.
   * *Obtención*: `https://console.mistral.ai`
6. **`neural`**:
   * *Propósito*: Plataforma de inferencia interna de la suite.
7. **`phonescan`** (Numverify):
   * *Propósito*: Obtener país, operadora telefónica y validez de un número en análisis OSINT.
   * *Obtención*: `https://numverify.com/dashboard`

### 🔹 Funcionamiento Interno del Comando
1. Si ya existe una API key configurada en las variables de i-HakLab (`$APIKEY_<plataforma>`), el script solicita confirmación al usuario antes de sobrescribirla para prevenir pérdidas accidentales.
2. Solicita la clave vía prompt interactivo (`╰──➤`).
3. Emplea un reemplazo automático de texto por flujo con `sed` para inyectar la nueva directiva de exportación persistente de la API key directamente dentro del archivo `$HOME/.local/etc/i-Haklab/variables`.
