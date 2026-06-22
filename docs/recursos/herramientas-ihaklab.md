# i-HakLab: manual completo, ayuda y referencia de comandos 🚀

> Fuente base: `i-Haklab/README.md`, `i-Haklab/.deb/usr/share/man/man1/i-Haklab.1` y salida real de `i-HakLab help`.

## 1. ¿Qué es i-HakLab?

**i-HakLab v3.12** es un laboratorio de hacking para **Termux/Android** creado por **@Ivam3 / Ivam3byCinderella**. Su objetivo es llevar herramientas, frameworks y flujos de trabajo típicos de un entorno Linux de escritorio a la palma de la mano mediante Termux.

El proyecto agrupa herramientas **open source** recomendadas por Ivam3 para:

- OSINT.
- Pentesting.
- Escaneo y búsqueda de vulnerabilidades.
- Explotación y post-explotación.
- Automatización de tareas en Termux.
- Laboratorios vulnerables para práctica.
- Material educativo: libros, tutoriales y guías.
- Entornos Linux en `proot` y escritorio gráfico con XFCE4/Termux Wayland.
- Flujo de desarrollo y “vibe coding” con asistentes IA en Termux.

> ⚠️ **Aviso legal:** el uso de i-HakLab debe realizarse únicamente en entornos propios, autorizados o de laboratorio. Si se viola la ley con su uso, la responsabilidad recae en la persona usuaria. Los autores no se responsabilizan por mal uso, daños o actividad no autorizada.

---

## 2. Referencias rápidas críticas

| Elemento | Dato clave |
|---|---|
| Login por defecto | `Ivam3byCinderella` |
| `4share` | `Admin:password` / `admin:password` |
| `servers4test` bWAPP | `bee:bug` |
| `servers4test` DVWA | DB/config `root:root` |
| `servers4test` mutillidae | DB/config `root` |
| Wrapper `apt` | `~/.local/bin/apt` |
| Wrapper `npm` | `~/.local/bin/npm` |
| Wrapper `pnpm` | `~/.local/bin/pnpm` |
| Automatización postinstalación | `~/.local/libexec/pkg2conf` |

---

## 3. Relación con Termux

Termux es un emulador de terminal para Android que expone un entorno de línea de comandos y paquetes compilados/adaptados para Android mediante `apt`. i-HakLab se construye sobre Termux para facilitar la instalación, configuración y uso de herramientas de seguridad, desarrollo y automatización.

i-HakLab usa **Oh My Fish / fish shell** como shell interactiva predeterminada, aunque permite cambiar a `bash` o `zsh`.

---

## 4. Instalación

### Opción 1: instalar desde repositorio APT recomendado

```bash
yes|apt install wget gnupg && \
mkdir -p $PREFIX/etc/apt/sources.list.d && \
wget https://raw.githubusercontent.com/ivam3/termux-packages/gh-pages/ivam3-termux-packages.list -O \
$PREFIX/etc/apt/sources.list.d/ivam3-termux-packages.list && \
curl -fsSL "https://raw.githubusercontent.com/ivam3/termux-packages/gh-pages/dists/stable/public_key.gpg" \
|gpg --dearmor|tee "$PREFIX/etc/apt/trusted.gpg.d/ivam3.gpg" >/dev/null && \
apt update && apt install i-haklab
```

### Opción 2: clonar el repositorio

```bash
git clone https://github.com/ivam3/i-Haklab
cd i-Haklab
chmod +x setup
bash setup
```

### Opción 3: instalar un `.deb` desde releases

1. Ir a la sección de releases del proyecto.
2. Descargar el archivo `.deb` deseado.
3. Instalarlo con:

```bash
apt install ./ruta/al/archivo/i-haklab_example_all.deb
```

---

## 5. Actualización

Para mantenerse en la versión más reciente publicada en el repositorio configurado:

```bash
apt update i-haklab
```

---

## 6. Ayuda y documentación integrada

### Ayuda rápida

```bash
i-HakLab help
```

Muestra el panel de ayuda con opciones de configuración, automatización y comandos directos.

### Página de manual

```bash
man i-Haklab
```

La página de manual instalada describe la sintaxis general:

```bash
i-Haklab [OPTION]... [ARG]
```

> Nota de escritura: en las fuentes aparecen variantes como `i-HakLab`, `i-Haklab` e `i-haklab`. El comando mostrado por la ayuda es `i-Haklab`/`i-HakLab`; el paquete APT se instala como `i-haklab`.

> Nota de versión recuperada del respaldo: la opción antigua `QG` — Quick Guides — ya no aparece en el comando `show` de la ayuda v3.12; el material educativo queda concentrado en `show books`, `show tutorials` y manuales renderizados con herramientas como `glow`.

---

## 7. Soporte, comunidad y recursos

- Chat IRC desde i-HakLab:

```bash
i-HakLab weechat
```

- Grupo de Telegram de soporte: `https://t.me/Ivam3by_Cinderella`
- Canal/recursos oficiales de la comunidad: `https://ivam3.github.io/#/redes`
- YouTube: `https://www.youtube.com/c/Ivam3byCinderella`
- GitHub del autor: `https://github.com/ivam3`
- DeepWiki del proyecto i-HakLab: `https://deepwiki.com/ivam3/i-HakLab`

---

## 8. Opciones de configuración (`Setting Options`)

| Comando | Argumentos | Función |
|---|---:|---|
| `i-HakLab about` | `<nombre_herramienta>` | Muestra información sobre una herramienta o framework. Ejemplo: `i-HakLab about crunch`. |
| `i-HakLab aptup` | — | Actualiza Termux manualmente paquete por paquete. |
| `i-HakLab help` | — | Muestra el menú de ayuda. |
| `i-HakLab passwd` | `set\|new` | Configura o cambia el login de Termux. Soporta contraseña o huella. |
| `i-HakLab pd` | `<distro> [X11]` / `list` | Ejecuta distribuciones Linux en entorno `proot`. `X11` levanta entorno gráfico. |
| `i-HakLab setapikey` | — | Configura API keys utilizadas por funciones de i-HakLab. |
| `i-HakLab setbanner` | — | Activa, desactiva o personaliza el banner de i-HakLab. |
| `i-HakLab setshell` | — | Cambia la shell entre `bash`, `zsh` y `fish` — predeterminada. |
| `i-HakLab setuser` | — | Configura el nombre de usuario de i-HakLab. |
| `i-HakLab show` | `alltools` | Lista herramientas/frameworks disponibles. |
| `i-HakLab show` | `instatools` | Muestra herramientas/frameworks instalados. |
| `i-HakLab show` | `books` | Muestra libros disponibles para descargar. |
| `i-HakLab show` | `tutorials` | Muestra tutoriales disponibles. |
| `i-HakLab speedtest` | — | Ejecuta una prueba de velocidad de red. |
| `i-HakLab version` | — | Muestra la versión instalada. |
| `i-HakLab weechat` | — | Conecta al chat IRC Ivam3byCinderella. |
| `i-HakLab Xwayland` | — | Ejecuta X server sobre Termux Wayland con XFCE4 como window manager. |

### Ejemplos rápidos

```bash
i-HakLab about crunch
i-HakLab pd list
i-HakLab pd alpine
i-HakLab pd alpine X11
i-HakLab passwd set
i-HakLab passwd new
i-HakLab show alltools
i-HakLab show instatools
i-HakLab show books
i-HakLab show tutorials
```

---

## 9. Automatizaciones (`Automatization Options`)

| Comando | Argumentos | Función |
|---|---:|---|
| `i-HakLab apkactivity` | `<ruta_apk>` | Obtiene la actividad principal de un archivo APK. |
| `i-HakLab androforensic` | `secretCodes\|airscope\|dumpsys\|extract <target>` | Extrae información de dispositivos Android vía ADB. |
| `i-HakLab backup` | `create\|restore` | Crea o restaura respaldos de Termux. |
| `i-HakLab binchecker` | — | Obtiene información sobre BINs — CC/DC. |
| `i-HakLab bruteforce` | `ftp\|mail\|ssh\|telnet` | Automatiza fuerza bruta contra servicios autorizados/laboratorio. |
| `i-HakLab chatAI` | `--help` / `-h` | Conecta con OpenAI API para interactuar con ChatGPT-3 desde CLI. |
| `i-HakLab ESmsg` | `encode\|decode` | Codifica o decodifica mensajes secretos en archivo ASCII. |
| `i-HakLab fakeID` | `<opciones+args>` | Crea una identidad ficticia con email y teléfono real. |
| `i-HakLab tunnel` | `<puerto+subdominio>` | Inicia cliente SSH para solicitar TCP port forwarding. |
| `i-HakLab handler` | `<archivo.rc>` | Inicia handler en `msfconsole` con configuración previa. |
| `i-HakLab msf` | `dirscan\|embed\|payapk\|payexe\|paypdf\|shodan` | Automatizaciones de Metasploit. |
| `i-HakLab ngroklink` | — | Muestra el enlace actual de ngrok. |
| `i-HakLab ngrokssh` | `<puerto+protocolo+archivo>` | Conecta con servidores ngrok vía protocolo SSH. |
| `i-HakLab payvid` | — | Oculta una reverse shell dentro de un video explotando Linux OS. |
| `i-HakLab phonescan` | `<número>` | Escanea información de un número telefónico. |
| `i-HakLab qemufy` | `<archivo.zip\|rm>` | Convierte OVAs y ejecuta máquinas virtuales QEMU en Termux sin root. |
| `i-HakLab servers4test` | — | Inicializa aplicaciones web deliberadamente inseguras para pentesting. |
| `i-HakLab 4share` | `<server-name>` | Inicializa servidor web para compartir archivos remotamente y de forma segura. |
| `i-HakLab usbtest` | `<ruta_dispositivo>` | Prueba dispositivos USB conectados vía OTG. |

### Subcomandos de `androforensic`

| Subcomando | Descripción |
|---|---|
| `secretCodes` | Escanea paquetes Android instalados y extrae códigos secretos de marcador. |
| `airscope` | Radar Wi‑Fi para dispositivos Android vía ADB. |
| `dumpsys` | Vuelca información del sistema del dispositivo Android objetivo vía ADB. |
| `extract` | Extracción de datos ADB y snapshot del sistema. |

Ejemplo:

```bash
i-HakLab androforensic dumpsys 192.168.1.58:41771
```

### Subcomandos de `backup`

```bash
i-HakLab backup create in     # almacenamiento interno
i-HakLab backup create ex     # SD externa
i-HakLab backup restore ruta/al/archivo.tar.gz
```

### Subcomandos de `msf`

| Subcomando | Descripción | Ejemplo |
|---|---|---|
| `dirscan` | Enumera directorios/subdirectorios de un servidor. | `i-HakLab msf dirscan 10.10.10.242` |
| `embed` | Inserta payload de Metasploit en APK legítima. | `i-HakLab msf embed 6.tcp.ngrok.io 4546 /ruta/app.apk` |
| `payapk` | Crea payload APK codificado. | `i-HakLab msf payapk 6.tcp.ngrok.io 23453` |
| `payexe` | Crea payload EXE codificado. | `i-HakLab msf payexe 192.168.0.1 8080` |
| `paypdf` | Crea payload PDF codificado. | `i-HakLab msf paypdf` |
| `shodan` | Busca servidores webcam vulnerables usando Metasploit/Shodan. | `i-HakLab msf shodan` |

### Otros ejemplos de automatización

```bash
i-HakLab apkactivity /ruta/app.apk
i-HakLab bruteforce ftp
i-HakLab bruteforce mail usuario@dominio.com
i-HakLab chatAI -h
i-HakLab ESmsg encode
i-HakLab ESmsg decode
i-HakLab tunnel -p 4444 -s my-subdomain
i-HakLab ngrokssh -p 4546 -t http -f /ruta/id_rsa
i-HakLab ngrokssh -p 8080 -t tcp
i-HakLab phonescan 525584923476
i-HakLab qemufy VM_image.zip
i-HakLab qemufy rm
i-HakLab 4share localtunnel
i-HakLab 4share localhost.run
i-HakLab 4share cloudflared
i-HakLab usbtest /dev/bus/usb/001
```

> En `4share`, la ayuda indica credenciales por defecto: `Admin:password`.

---

## 10. Comandos directos

Estos comandos no requieren el prefijo `i-HakLab`; se ejecutan directamente en la terminal.

| Comando | Función |
|---|---|
| `apt` | Instala, elimina y configura paquetes/herramientas/frameworks. |
| `adminfiles` | Copia archivos desde almacenamiento interno/externo al directorio de Termux. |
| `bat` | Alternativa a `cat` con resaltado de texto. |
| `cmd` | Gestiona ajustes principales de Android desde Termux. |
| `df` | Muestra información de memoria/montajes. |
| `du` | Muestra peso de directorios y archivos recursivamente. |
| `fixer` | Automatiza solución de problemas de Termux. |
| `fzf` | Buscador difuso interactivo. |
| `gitbrowsering` | Busca repositorios de GitHub por CLI. |
| `glow` | Lee archivos Markdown con resaltado/salida enriquecida. |
| `LOCALHOST` | Muestra la IP actual en LAN. |
| `lock` | Bloquea la pantalla de Termux. |
| `mypip` | Muestra la IP pública. |
| `openvpn` | Abre la aplicación Android de OpenVPN. |
| `omf` | Cambia tema de Oh My Fish. |
| `phantom-ps` | Cambia el límite de procesos fantasma a `2147483647`. Requiere división de pantalla/opciones de desarrollador según la ayuda. |
| `pm` | Gestor de paquetes Android. |
| `postgresql` | Inicia, detiene o reinicia PostgreSQL. |
| `proxy` | Ejecuta comandos CLI sobre Tor/proxychains. |
| `rmcache` | Elimina caché de sesión, temporales y paquetes residuales APT. |
| `serverapache` | Inicializa servidor Apache. |
| `serverphp` | Inicializa servidor PHP. |
| `sudo` | Ejecuta comandos o inicia entorno como falso root. |
| `telegram` | Abre la aplicación Android de Telegram. |
| `traductor` | Inicia traductor de línea de comandos. |
| `yazi` | Gestor de archivos en terminal. |

---

## 11. Funciones destacadas del ecosistema

### Información de herramientas

```bash
i-HakLab about <nombre_herramienta>
```

Permite consultar información específica de una herramienta o framework integrado.

### Shell y personalización

```bash
i-HakLab setshell
i-HakLab setbanner
i-HakLab setuser
omf theme
```

- Cambia entre `bash`, `zsh` y `fish`.
- Personaliza banner y usuario.
- Usa Oh My Fish para temas de shell.

### Login de sesión

```bash
i-HakLab passwd set
i-HakLab passwd new
```

Permite configurar login de Termux por contraseña — por defecto se menciona `Ivam3byCinderella` en el README — o huella.

### Distribuciones Linux con `proot`

```bash
i-HakLab pd list
i-HakLab pd alpine
i-HakLab pd alpine X11
```

Ejecuta distribuciones Linux en modo CLI o con entorno gráfico usando `X11`.

### Escritorio gráfico con Termux Wayland

```bash
apt install termux-desktop-xfce
i-HakLab Xwayland
```

Levanta XFCE4 como window manager sobre Termux Wayland.

### Material educativo

```bash
i-HakLab show books
i-HakLab show tutorials
```

Permite explorar libros y tutoriales incluidos para aprender herramientas, shell y uso de Termux.

### Herramientas disponibles e instaladas

```bash
i-HakLab show alltools
i-HakLab show instatools
```

El README menciona más de 100 herramientas/frameworks disponibles desde el ecosistema y el repositorio `ivam3/termux-packages`.

### Red e IP

```bash
i-HakLab speedtest
mypip
LOCALHOST
```

- `speedtest`: prueba la velocidad de la red.
- `mypip`: muestra IP pública.
- `LOCALHOST`: muestra IP en LAN.

### Túneles y exposición de servicios

```bash
i-HakLab tunnel -p 4444 -s my-subdomain
i-HakLab 4share localtunnel
i-HakLab 4share localhost.run
i-HakLab 4share cloudflared
i-HakLab ngroklink
```

Facilita port forwarding, enlaces ngrok y servidores temporales para compartir archivos o exponer servicios de laboratorio.

### QEMU y máquinas virtuales sin root

```bash
i-HakLab qemufy VM_image.zip
i-HakLab qemufy rm
```

Convierte imágenes OVA/ZIP y ejecuta VMs QEMU sobre Termux sin root.

### Laboratorios vulnerables

```bash
i-HakLab servers4test
```

Inicializa aplicaciones web inseguras para practicar pentesting; el README menciona bWAPP, DVWA y Mutillidae.

### Desarrollo asistido por IA en Termux

El README indica que i-HakLab configura varias herramientas instaladas mediante `apt`, `npm`, `pip`, `gem`, etc. Por ejemplo, tras instalar `neovim`, la suite puede preparar configuración de editor, GitHub Copilot y asistentes de IA como Gemini, Qwen Code, OpenCode, OpenClaw, Claude Code, Codex, Ollama, MistralAI y otros para una experiencia de “vibe coding” en Termux.

---


## 12. Arsenal de herramientas incluidas y clasificación técnica

i-HakLab no solo expone comandos de automatización, también funciona como un **arsenal curado** con manuales y guías de más de 100 herramientas/frameworks integrados en Termux.

### Inteligencia Artificial y asistencia autónoma

- **`chatAI` / `chatgpt.md`**: asistente conversacional de terminal conectado a API de OpenAI.
- **`antigravity-cli`**: agente autónomo ejecutable nativo en Go.
- **`claude-code`**: herramienta de programación y edición autónoma por CLI, adaptada para entornos glibc/Termux.
- **`opencode` / `qwen-code`**: utilidades de código y modelos abiertos por CLI.
- **`minimax-cli` / `mimocode`**: herramientas complementarias para desarrollo asistido por IA.
- **`codex`, `gemini-cli`, `github-copilot`, `mistralAI`, `ollama`**: herramientas mencionadas en el ecosistema de “vibe coding” sobre Termux.

### Análisis forense móvil e ingeniería inversa Android

- **`androforensic`**: suite de extracción e investigación digital vía ADB.
- **`androbugs`**: escáner de vulnerabilidades de APKs.
- **`apktool` / `apksigner`**: descompilación, modificación, empaquetado y firma de APKs.
- **`dex2jar` / `axmlprinter2` / `xml2axml`**: conversión Dalvik/Java y análisis de manifiestos binarios.
- **`appshark`**: escaneo estático avanzado de flujos de vulnerabilidad en apps Android.
- **`mvt` — Mobile Verification Toolkit**: herramienta forense para detectar trazas de compromiso o malware móvil.

### Auditoría de redes y reconocimiento OSINT

- **`nmap`**: descubrimiento de red, escaneo de puertos y detección de servicios/sistemas.
- **`amass` / `sublist3r` / `gobuster`**: descubrimiento de subdominios, enumeración DNS y fuerza bruta de rutas.
- **`aquatone` / `finalrecon`**: reconocimiento visual y mapeo automatizado de objetivos web.
- **`dnsenum` / `dns2tcp`**: análisis DNS, enumeración y túneles sobre DNS.
- **`shodan` / `ghunt`**: búsqueda OSINT en motores IoT y cuentas/servicios.
- **`sherlock` / `holehe` / `fbi`**: rastreo de perfiles, usuarios y correos en servicios públicos.
- **`osintgram` / `octosuite`**: recolección especializada en Instagram y GitHub.

### Explotación, redes y fuerza bruta

- **`metasploit-framework`**: plataforma para pruebas de penetración y explotación controlada.
- **`bettercap` / `aircrack-ng`**: auditoría Wi‑Fi, MITM y análisis de tráfico.
- **`beef`**: Browser Exploitation Framework para auditorías del lado cliente.
- **`hydra-gtk` / `johntheripper` / `hashcat`**: auditoría de contraseñas y cracking en laboratorio/autorizado.
- **`sqlmap` / `dirb` / `vulnx`**: detección automatizada de inyección SQL, rutas y vulnerabilidades CMS.
- **`evilginx2` / `lockphish` / `nexphisher`**: frameworks para simulación controlada de phishing y pruebas 2FA.

### Entorno, visualización y utilidades del sistema

- **`fzf`**: selector difuso interactivo para acelerar menús y selección de archivos.
- **`glow` / `markdown-viewer`**: renderizado de Markdown en terminal.
- **`traductor` / `translate-shell`**: traducción de documentación técnica desde CLI.
- **`tmux` / `neovim` / `vim`**: multiplexación de terminal y edición avanzada.
- **`cloudflared` / `ngrok` / `localtunnel`**: túneles para exponer servicios locales.
- **`qemufy` / `termux-docker-qemu` / `udocker`**: virtualización/emulación y contenedores en espacio de usuario.
- **`engram`**: motor persistente de memoria y aprendizaje continuo usado por el proyecto.

---

## 13. Configuración del entorno, API keys y wrappers invisibles

La suite i-HakLab instala variables de entorno, aliases y **wrappers invisibles** que cambian el comportamiento de comandos comunes para que los paquetes queden configurados automáticamente dentro del ecosistema.

### Archivo `envvariables`

El archivo base está en:

```bash
~/.local/etc/i-Haklab/envvariables
```

Define, entre otras cosas:

- `DISPLAY=:0` para entorno gráfico/Termux Wayland.
- `USER=i-HakLab` como usuario por defecto si no se cambia con `i-HakLab setuser`.
- `GPG_TTY=$(tty)`.
- `GYP_DEFINES="android_ndk_path=''"` para compilación de módulos Node nativos.
- `HOME=/data/data/com.termux/files/home`.
- `PATH="$HOME/.local/bin:/data/data/com.termux/files/usr/bin:$HOME/go/bin"`.
- `GOPATH`, `GOROOT`, `GOCACHE`, `GOMODCACHE` para Go.
- `JAVA_HOME`, `LD_LIBRARY_PATH`, `LLVM_BUILD`, `LLVM_HOME`.
- `CC=clang`, `CXX=clang++`, `ANDROID_NDK_HOME`, `ANDROID_API_LEVEL=24`.
- `TOOLS=$HOME/.local/share`.
- `VSCODE_EXTENSIONS_DIR=$HOME/.local/share/code-server/extensions`.

Aliases definidos por el entorno:

```bash
alias la="ls -a"
alias ll="ls -l"
alias du="du -hP"
alias df="duf"
alias bat="bat -f --theme 'Visual Studio Dark+'"
alias postgresql="pg_ctl -D /data/data/com.termux/files/usr/var/lib/postgresql"
```

### Comando `i-HakLab setapikey`

El comando:

```bash
i-HakLab setapikey
```

funciona como gestor interactivo para guardar claves de servicios externos usados por módulos de IA y OSINT. Las claves se persisten en el entorno de i-HakLab con nombres tipo `APIKEY_<plataforma>` dentro de la configuración local.

| Plataforma | Proveedor / uso | Dónde obtener la clave |
|---|---|---|
| `chatGPT` | OpenAI / chatAI | `https://platform.openai.com/account/api-keys` |
| `claude` | Anthropic / Claude | `https://platform.claude.com` |
| `deepseek` | DeepSeek | `https://api-docs.deepseek.com/` |
| `gemini` | Google AI Studio | `https://aistudio.google.com` |
| `mistralAI` | Mistral AI | `https://console.mistral.ai` |
| `neural` | Integración de la suite | — |
| `phonescan` | Numverify / escaneo telefónico | `https://numverify.com/dashboard` |

Este contenido complementa la guía específica de variables y API keys enlazada desde `docs/termux/variables-y-api-keys.md`.

### Inyección de wrappers en `$PATH`

La clave del diseño es que `~/.local/bin` aparece **antes** de `$PREFIX/bin` en el `PATH`. Por eso estos wrappers se ejecutan antes que los binarios reales:

```bash
i-Haklab/.deb/home/.local/bin/apt
i-Haklab/.deb/home/.local/bin/npm
i-Haklab/.deb/home/.local/bin/pnpm
```

Cada wrapper conserva compatibilidad delegando al binario real cuando no necesita intervenir:

```bash
$PREFIX/bin/apt
$PREFIX/bin/npm
$PREFIX/bin/pnpm
```

### Wrapper `apt`

El wrapper `apt` intercepta principalmente:

```bash
apt install ...
apt reinstall ...
apt search ...
```

Cuando detecta que el nombre solicitado no debería instalarse con APT nativo, propone ejecutar el gestor correcto y pide confirmación.

| Tipo detectado | Instalador propuesto | Ejemplos |
|---|---|---|
| Módulo Python | `python3 -m pip install` | `bloodhound`, `frida`, `h8mail`, `hashid`, `holehe`, `mvt`, `objection`, `octosuite`, `orbitaldump`, `osrframework`, `phoneintel`, `scrapy`, `shodan`, `snscrape`, `speedtest-cli`, `sqlmap`, `wfuzz` |
| Gema Ruby | `gem install` | `bettercap`, `aquatone` |
| Módulo Node.js | `npm install -g` | `bash-obfuscate`, `codex`, `copilot-cli`, `gemini-cli`, `localtunnel`, `minimax-cli`, `n8n`, `pnpm`, `open-lovable`, `qwen-code`, `twifo-cli` |
| Paquete normal | `$PREFIX/bin/apt` | cualquier paquete no interceptado |

Normalizaciones internas relevantes:

| Alias | Paquete real |
|---|---|
| `gemini-cli` | `@google/gemini-cli` |
| `qwen-code` | `@qwen-code/qwen-code` |
| `claude-code` | `@anthropic-ai/claude-code` |
| `codex` | `@mmmbuto/codex-cli-termux@latest` |
| `copilot-cli` / `github-copilot` | `@github/copilot` |
| `minimax-cli` | `mmx-cli` |

Después de una instalación/reinstalación APT normal, el wrapper llama a `pkg2conf` si la herramienta aparece en la lista de paquetes configurables.

### Wrapper `npm`

El wrapper `npm` interviene en:

```bash
npm install ...
npm update ...
npm uninstall ...
```

Funciones principales:

- Normaliza alias como `gemini-cli`, `qwen-code`, `claude-code`, `codex`, `copilot-cli`, `github-copilot` y `minimax-cli`.
- Prepara instalaciones especiales de `n8n`, `pnpm` y `open-lovable`.
- Ejecuta `pkg2conf` después de instalar paquetes integrables.
- Para otros comandos, delega a `$PREFIX/bin/npm`.

Automatización especial de `n8n` con npm:

1. Instala dependencias APT: `nodejs-lts`, `libsqlite`, `sqlite`.
2. Instala globales auxiliares: `pm2`, `gyp`, `node-gyp`.
3. Crea `~/.n8n` y `~/.gyp`.
4. Genera `~/.gyp/include.gypi` compatible con Android/Termux.
5. Luego instala `n8n` con el npm real.

Automatización especial de `pnpm` desde npm:

```bash
corepack enable
pnpm setup
```

También intenta asegurar que `~/.local/share/pnpm/bin` quede disponible en el archivo de configuración de la shell activa.

Automatización especial de `open-lovable`:

- Borra instalación previa en `~/.local/share/open-lovable` si existe.
- Clona `https://github.com/firecrawl/open-lovable.git`.
- Habilita `corepack`.
- Ejecuta la instalación desde el directorio clonado.

### Wrapper `pnpm`

El wrapper `pnpm` interviene en:

```bash
pnpm install ...
pnpm update ...
pnpm uninstall ...
```

Funciones principales:

- Normaliza los mismos alias Node.js que el wrapper `npm`.
- Automatiza `n8n` y `open-lovable`.
- Ejecuta `pkg2conf` si el paquete aparece en `listofpkg2conf`.
- Para otros comandos, delega a `$PREFIX/bin/pnpm`.

Automatización especial de `n8n` con pnpm:

1. Instala `nodejs-lts`, `libsqlite` y `sqlite`.
2. Instala `pm2`, `gyp` y `node-gyp` con `pnpm install -g`.
3. Crea `~/.n8n` y `~/.gyp`.
4. Genera `~/.gyp/include.gypi`.
5. Ejecuta:

```bash
pnpm approve-builds -g
```

### Automatización `pkg2conf`

El script de post-configuración está en:

```bash
i-Haklab/.deb/home/.local/libexec/pkg2conf
```

Se ejecuta así:

```bash
bash ~/.local/libexec/pkg2conf <paquete>
```

Su propósito es aplicar configuraciones posteriores a la instalación: enlaces simbólicos, archivos de configuración, parches, funciones de shell, ajustes para Android/Termux y asistentes adicionales.

La lista local de paquetes que disparan configuración adicional está en:

```bash
~/.local/etc/i-Haklab/Tools/listofpkg2conf
```

Incluye:

```text
apache2, bash, clamav, claude-code, fish, gdb, gemini-cli, localtunnel,
mariadb, mvt, n8n, nano, neovim, open-lovable, phpmyadmin, privoxy,
proxychains-ng, python, qwen-code, radare2, tigervnc, tmux, tor, vim,
youtubedr, zsh
```

Acciones importantes observadas en `pkg2conf`:

| Paquete | Configuración aplicada |
|---|---|
| `apache2` / `phpmyadmin` | Crea configuración local, descarga `httpd.conf`, `php_module.conf`, `config.inc.php` y enlaza hacia `$PREFIX/etc`. |
| `bash`, `fish`, `zsh` | Instala/enlaza archivos rc y plugins; `zsh` añade autosuggestions y syntax highlighting. |
| `clamav` | Activa `freshclam.conf` y ejecuta `freshclam`. |
| `gdb` | Clona PEDA y configura `~/.gdbinit`. |
| `@google/gemini-cli` | Parchea `clipboardy` para comportamiento Android. |
| `@qwen-code/qwen-code` / `@anthropic-ai/claude-code` | Instala `mistral-vibe` con pip. |
| `localtunnel` | Parchea `openurl.js`. |
| `mariadb` | Inicializa/actualiza MariaDB y establece usuario root local. |
| `mvt` | Instala dependencias criptográficas y parchea archivos Python/ADB. |
| `n8n` | Crea función fish `n8n` con variables SQLite y tips de `pm2`. |
| `nano` | Genera `.nanorc` con numeración, mouse, colores e indentación. |
| `neovim` | Descarga configuración, instala paquetes npm/pip auxiliares y language servers. |
| `open-lovable` | Ajusta `package.json` para usar `NEXT_DISABLE_TURBOPACK=1 next dev`. |
| `privoxy`, `proxychains-ng`, `tor` | Instala/enlaza configuraciones de proxy/Tor. |
| `radare2` | Actualiza `r2pm` e instala `r2ghidra-sleigh`. |
| `tigervnc` | Genera `~/.vnc/xstartup` con `startxfce4`. |
| `tmux` | Descarga configuración, enlaza `.tmux.conf` y establece fish como shell por defecto. |
| `vim` | Instala configuración, plugins y extensiones Coc. |
| `youtubedr` | Prepara `.netrc` y `termux-url-opener`. |

---

## 14. Credenciales por defecto y servicios activados

### Login de i-HakLab

El login de i-HakLab/Termux puede activarse con:

```bash
i-HakLab passwd set
```

La clave de acceso por defecto indicada por el README es:

```text
Ivam3byCinderella
```

El sistema permite cambiarla con:

```bash
i-HakLab passwd new
```

Internamente, la contraseña se guarda cifrada en:

```bash
~/.local/etc/i-Haklab/.Ivam3byCinderella
```

El comando `passwd set` también permite elegir entre acceso por contraseña, huella digital o desactivar el login.

### `i-HakLab 4share`

El comando:

```bash
i-HakLab 4share <localtunnel|localhost.run|cloudflared>
```

levanta un servidor Apache apuntando a Veno File Manager en:

```bash
~/.local/var/service/www/veno-file-manager/vfm/
```

La ayuda de `i-HakLab help` indica credenciales por defecto:

```text
Admin:password
```

La documentación interna de Veno File Manager incluida en el paquete especifica:

```text
username: admin
password: password
```

El script muestra además:

- URL LAN: `http://127.0.0.1:<puerto>` o loopback detectado.
- Subdominio para localtunnel basado en el usuario: `<USER>-4share`.
- Password temporal de LocalTunnel consultado desde `https://loca.lt/mytunnelpassword`.

Servidores soportados:

```bash
i-HakLab 4share localtunnel
i-HakLab 4share localhost.run
i-HakLab 4share cloudflared
```

### `i-HakLab servers4test`

El comando:

```bash
i-HakLab servers4test
```

inicializa aplicaciones web deliberadamente vulnerables para pentesting local/autorizado. Usa PHP y MariaDB, pide la contraseña de base de datos, crea bases y sirve el sitio con:

```bash
php -S <loopback>:<puerto> -t ~/.local/var/service/www/servers4test/<plataforma>
```

Plataformas disponibles en el selector:

```text
bWAPP
DVWA
mutillidae
```

Credenciales y datos relevantes observados en los scripts/configuración incluida:

| Plataforma | Credenciales / configuración por defecto |
|---|---|
| **bWAPP** | Usuario web principal `bee`, contraseña `bug`. También se insertan usuarios `A.I.M.` y `bee` en la base con hash de `bug`. Configuración DB: usuario `root`; el password DB se ajusta al valor ingresado al iniciar `servers4test`, y en archivos incluidos aparece `root` como password local de configuración. |
| **DVWA** | El script cambia la configuración DB a usuario `root` y password `root` en `config.inc.php`; crea la base `dvwa`. Las credenciales web por defecto de DVWA normalmente se gestionan desde la app tras crear/resetear la DB. |
| **mutillidae** | Crea base `mutillidae` y parchea configuración para password DB `root` en archivos internos. |

> Recomendación: estos servicios deben levantarse solo en laboratorio/local o en redes controladas. Si se exponen con túneles, cambiar credenciales por defecto y limitar acceso.

---

## 15. Mapa rápido por caso de uso

| Necesidad | Comandos principales |
|---|---|
| Ver ayuda | `i-HakLab help`, `man i-Haklab` |
| Actualizar entorno | `i-HakLab aptup`, `apt update i-haklab` |
| Cambiar shell | `i-HakLab setshell` |
| Personalizar usuario/banner | `i-HakLab setuser`, `i-HakLab setbanner` |
| Consultar herramientas | `i-HakLab about <tool>`, `i-HakLab show alltools`, `i-HakLab show instatools` |
| Aprender | `i-HakLab show books`, `i-HakLab show tutorials` |
| ADB/forense Android | `i-HakLab androforensic ...`, `i-HakLab apkactivity ...` |
| Metasploit | `i-HakLab msf ...`, `i-HakLab handler ...` |
| Túneles/compartir archivos | `i-HakLab tunnel ...`, `i-HakLab 4share ...`, `i-HakLab ngrokssh ...` |
| Laboratorio vulnerable | `i-HakLab servers4test` |
| VM sin root | `i-HakLab qemufy ...` |
| Escritorio gráfico | `i-HakLab Xwayland` |
| Backup | `i-HakLab backup create`, `i-HakLab backup restore` |
| Limpieza/fixes | `fixer`, `rmcache`, `phantom-ps` |

---

## 16. Resumen ejecutivo

i-HakLab convierte Termux en un laboratorio portátil de ciberseguridad, desarrollo y automatización. Sus pilares son:

1. **Acceso simplificado a herramientas** mediante `apt`, comandos directos y `i-HakLab show/about`.
2. **Automatización de tareas complejas** como Metasploit, túneles, análisis Android, backups y QEMU.
3. **Entorno personalizado** con shell fish/Oh My Fish, banners, usuario y configuración de paquetes.
4. **Aprendizaje integrado** con libros, tutoriales y soporte comunitario.
5. **Uso responsable** orientado a laboratorios, investigación autorizada, educación y desarrollo de contramedidas.
