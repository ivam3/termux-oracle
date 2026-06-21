# Gestión de Paquetes en Termux: `pkg` vs `apt` 📦

Una duda recurrente en los canales de soporte es cuándo usar el comando `pkg` y cuándo utilizar `apt`. Aunque ambos interactúan con los mismos repositorios, tienen propósitos y comportamientos distintos en el entorno de Termux.

## El comando `pkg` (El gestor nativo de Termux)
`pkg` es un *wrapper* o envoltorio escrito en Bash desarrollado específicamente para Termux. Invoca internamente a `apt` pero realiza optimizaciones críticas automáticas.

### Ventajas de usar `pkg`:
1. **Actualización automática de fuentes:** Cada vez que ejecutas `pkg install <paquete>`, el script verifica y refresca automáticamente la lista de repositorios locales de manera rápida, previniendo errores de descarga `404`.
2. **Selección automática de espejos:** Elige los servidores réplica (mirrors) más cercanos o disponibles.
3. **Manejo simplificado:** Reduce la necesidad de escribir comandos compuestos largos.

### Comandos Comunes:
* Instalar un paquete: `pkg install <nombre>`
* Desinstalar un paquete: `pkg uninstall <nombre>`
* Buscar un paquete: `pkg search <palabra_clave>`

---

## El comando `apt` (Advanced Package Tool)
`apt` es el gestor clásico heredado de distribuciones Linux de la familia Debian. 

### Características de `apt` en Termux:
* **Mayor control:** Permite realizar operaciones avanzadas como purgar archivos de configuración residuales (`apt purge`), o manejar dependencias de forma quirúrgica.
* **Riesgo de desincronización:** Si ejecutas `apt install <paquete>` sin haber hecho previamente un `apt update`, el comando fallará si las firmas o versiones del repositorio cambiaron en el servidor remoto.

### Comandos Comunes:
* Actualizar lista de repositorios: `apt update`
* Actualizar todo el sistema: `apt upgrade` o `apt full-upgrade`

---

## 📌 La Regla de Oro de i-HakLab
Para evitar la corrupción de dependencias y garantizar que herramientas como `git`, `python`, `fzf` o `gawk` se instalen sin conflictos de firmas en Android:

> **Usa siempre `pkg install` para instalar herramientas individuales y utiliza `apt update && apt upgrade` únicamente durante el mantenimiento general de la terminal.**

---

## 🚀 3. Automatización de Paquetes en i-HakLab: Los Wrappers e Interceptores

El entorno interactivo de **i-HakLab** implementa una capa de automatización inteligente sobre la gestión de paquetes nativa de Termux. Para lograr esto, la suite instala **interceptores o wrappers** en la ruta local del usuario (`~/.local/bin/`) que sustituyen y redirigen las llamadas de comandos de `apt` y `npm`.

Esta arquitectura permite instalar herramientas complejas de ciberseguridad y automatización de forma desatendida sin lidiar con dependencias rotas de Android.

```mermaid
graph TD
    User([Usuario ejecuta comando]) -->|apt install pkg| AptWrapper[~/.local/bin/apt]
    User -->|npm install pkg| NpmWrapper[~/.local/bin/npm]
    
    AptWrapper -->|Detecta Python/Ruby/NodeJS| Redirect[Redirige a pip / gem / npm]
    AptWrapper -->|Nativo de Termux| SystemApt[Ejecuta apt del sistema]
    
    NpmWrapper -->|Resuelve dependencias y NDK| SystemNpm[Ejecuta npm del sistema]
    
    Redirect --> Pkg2Conf[~/.local/libexec/pkg2conf]
    SystemApt --> Pkg2Conf
    SystemNpm --> Pkg2Conf
    
    Pkg2Conf -->|Aplica parches y configuraciones| Config[Entorno configurado y listo]
```

### A. El Wrapper de APT (`~/.local/bin/apt`)
Cuando ejecutas `apt install <herramienta>`, este wrapper intercepta el nombre del paquete:
1. **Redirección Inteligente**: Detecta si el paquete es en realidad un módulo de otro ecosistema. Por ejemplo:
   * Si es un módulo de Python (ej: `sqlmap`, `shodan`, `mvt`, `frida`), cancela el `apt` nativo y lo redirige automáticamente a `python3 -m pip install`.
   * Si es un módulo global de Node.js (ej: `n8n`, `localtunnel`, `claude-code`, `gemini-cli`), lo desvía a `npm install -g`.
   * Si es una gema de Ruby (ej: `bettercap`, `aquatone`), lo redirige a `gem install`.
2. **Ejecución del Sistema**: Si el paquete es nativo, llama al binario original (`/data/data/com.termux/files/usr/bin/apt`).
3. **Fase de Autoconfiguración**: Si la instalación finaliza con éxito y el paquete requiere configuraciones post-instalación de la suite, invoca al orquestador **`pkg2conf`**.

### B. El Wrapper de NPM (`~/.local/bin/npm`)
Muchos módulos globales de Node.js fallan al compilarse en Android por diferencias en la ubicación de librerías del sistema o falta del NDK. El wrapper `npm` corrige esto de antemano:
* **Resolución de pre-requisitos de `n8n`**: Si instalas `n8n`, el wrapper instala previamente los paquetes nativos `nodejs-lts`, `libsqlite`, `sqlite`, y los módulos globales de compilación `pm2` y `node-gyp`. Además, genera automáticamente archivos temporales `.gyp/include.py` con variables NDK vacías para anular fallos del compilador.
* **Soporte de `pnpm`**: Configura corepack y escribe las rutas binarias necesarias en los archivos de perfil de la shell (`.bashrc`, `.zshrc`, `config.fish`).
* **Parcheo de código**: Lanza `pkg2conf` al finalizar la instalación.

---

## ⚙️ 4. El Orquestador de Post-Instalación: `pkg2conf` (`~/.local/libexec/pkg2conf`)

El script **`pkg2conf`** es un motor en Bash encargado de parchear el código fuente, crear enlaces simbólicos de configuración y arrancar demonios de forma desatendida tras la instalación de un paquete. 

A continuación se detallan algunos de los parches y configuraciones críticas que realiza de forma automatizada por paquete:

| Paquete / Herramienta | Acción de Automatización Realizada por `pkg2conf` |
| :--- | :--- |
| **`@google/gemini-cli`** | Parchea el archivo `index.js` del módulo `clipboardy` para corregir un fallo en la detección del portapapeles de Android en Termux (reemplaza `===` por `!==` en la lógica de android). |
| **`mvt` (Mobile Verification)** | Resuelve dependencias de criptografía vía `apt` e introduce dos parches: descarga un archivo `base.py` reparado para evitar un error de identación de Python y modifica `adb_device.py` para capturar fallos genéricos al importar conexiones USB en Android. |
| **`neovim` / `vim`** | Crea las carpetas de configuración, descarga una plantilla configurada de plugins y LSPs (`nvim.zip` / `setvim.zip`), la extrae, instala librerías de lenguajes vía npm/pip y ejecuta de forma desatendida la instalación interna de complementos. |
| **`mariadb`** | Realiza una configuración segura automatizada: arranca temporalmente el motor omitiendo las tablas de privilegios (`--skip-grant-tables`), asigna y encripta una clave por defecto para el usuario `root` (`root`), habilita el plugin `mysql_native_password`, y levanta el servicio de forma segura. |
| **`gdb`** | Clona la extensión de análisis gráfico/depuración **`peda`** en las carpetas de la suite y agrega la directiva de carga automática `source` en el archivo local `~/.gdbinit`. |
| **`tmux` / `zsh` / `bash` / `fish`** | Descarga plantillas de configuración y temas de la suite, realiza respaldos de tus archivos anteriores, crea enlaces simbólicos a las rutas activas y clona plugins de autocompletado y colores de manera automatizada. |
| **`apache2` / `phpmyadmin`** | Descarga configuraciones HTTP seguras, borra los archivos por defecto de la ruta del sistema de Termux y los reemplaza por enlaces simbólicos a los archivos de configuración de la suite local (`~/.local/etc/`). |
| **`youtubedr`** | Genera una configuración de credenciales en `~/.netrc` y crea un script de intercepción multimedia nativo en `/data/data/com.termux/files/usr/bin/termux-url-opener`. |
| **`localtunnel`** | Parchea el módulo global reemplazando el archivo `openurl.js` por una versión compatible descargada del servidor para evitar fallos de apertura de enlaces en consola. |
| **`tor` / `privoxy` / `proxychains-ng`** | Vincula las configuraciones a través de enlaces simbólicos y enlaza Privoxy con el puerto socks5 local de Tor (`127.0.0.1:9050`) para enrutar el tráfico de forma automatizada. |

