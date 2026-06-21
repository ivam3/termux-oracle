# Manual de Uso de i-HakLab y Arsenal de Herramientas 🚀

Este documento centraliza los métodos oficiales de consulta (`help`/`man`) de **i-HakLab** y detalla la lista clasificada de herramientas avanzadas integradas en la suite, obtenida directamente de los índices de manuales del sistema (`/Tools/Readme/`).

---

## 📖 1. Comandos Oficiales de Ayuda

El entorno interactivo de i-HakLab provee dos mecanismos principales para consultar la ayuda y la sintaxis de los comandos desde la terminal:

### A. El comando `i-HakLab help`
* **Uso:** Muestra el panel interactivo o listado rápido de opciones principales disponibles en el ecosistema, atajos de teclado y la configuración del menú inicial.
* **Propósito:** Ideal para referencias rápidas sobre cómo levantar los módulos de inteligencia artificial (`chatAI`), herramientas de red, o los scripts de automatización.

### B. El manual del sistema: `man i-HakLab`
* **Uso:** `man i-HakLab`
* **Propósito:** Abre la *man page* formal instalada en el sistema (actualizada en la versión v3.12). Detalla la sintaxis técnica completa de todas las opciones, variables de entorno soportadas y la arquitectura de directorios interna del proyecto.
* **Gotcha de la v3.12:** Recuerda que la opción antigua `QG` (Quick Guides) dentro del comando de visualización fue removida y consolidada en manuales directos renderizados con `glow` para optimizar espacio.

### C. Visualización de Material Educativo Integrado
El entorno interactivo de i-HakLab cuenta con accesos directos integrados para que la comunidad pueda descargar y visualizar tutoriales y libros técnicos directamente desde la consola:
* **`i-HakLab show tutorials`**: Despliega un menú interactivo con video tutoriales prácticos, guías de configuración y demostraciones de herramientas.
* **`i-HakLab show books`**: Permite explorar y descargar el catálogo de libros técnicos, manuales y guías de programación y seguridad integrados.

---

## ⚙️ 2. Arsenal de Herramientas Incluidas (Clasificación Técnica)

El repositorio local de i-HakLab cuenta con manuales detallados de más de 100 herramientas avanzadas listas para ejecución en Termux. A continuación se agrupan y enumeran las herramientas principales indexadas en el sistema:

### A. Inteligencia Artificial & Asistencia Autónoma
* **`chatAI` (`chatgpt.md`)**: Asistente conversacional de terminal de i-HakLab.
* **`antigravity-cli`**: Agente autónomo ejecutable nativo en Go.
* **`claude-code`**: Herramienta de programación y edición autónoma por CLI (adaptada para glibc).
* **`opencode` / `qwen-code`**: Modelos y utilidades de código CLI de código abierto.
* **`minimax-cli` / `mimocode`**: Herramientas complementarias de desarrollo asistido por IA.

### B. Análisis Forense Móvil & Ingeniería Inversa (Android)
* **`androforensic`**: Suite masiva para investigación digital y análisis forense en dispositivos Android.
* **`androbugs`**: Escáner de vulnerabilidades enfocado en fallos de seguridad en archivos APK.
* **`apktool` / `apksigner`**: Descompilación, modificación de recursos, empaquetado y firmado de APKs.
* **`dex2jar` / `axmlprinter2` / `xml2axml`**: Conversión de ejecutables Dalvik (`.dex`) a Java y decodificación de manifiestos binarios.
* **`appshark`**: Herramienta avanzada para el escaneo estático de flujos de vulnerabilidad en código de apps Android.
* **`mvt` (Mobile Verification Toolkit)**: Herramienta forense para detectar trazas de compromiso o malware (como Pegasus) en dispositivos móviles.

### C. Auditoría de Redes & Reconocimiento (OSINT)
* **`nmap`**: Escaneo avanzado de puertos, descubrimiento de red y detección de sistemas operativos.
* **`amass` / `sublist3r` / `gobuster`**: Descubrimiento de subdominios, enumeración DNS activa/pasiva y fuerza bruta de directorios.
* **`aquatone` / `finalrecon`**: Reconocimiento visual y mapeo automatizado de objetivos web.
* **`dnsenum` / `dns2tcp`**: Explotación, análisis de zonas DNS y tunelización sobre tráfico de nombres.
* **`shodan` / `ghunt`**: Integración con motores de búsqueda IoT e investigación de cuentas de usuario OSINT.
* **`sherlock` / `holehe` / `fbi`**: Rastreo de perfiles e hilos de usuarios en redes sociales y registros de correos.
* **`osintgram` / `octosuite`**: Herramientas especializadas de recolección de inteligencia en Instagram y GitHub.

### D. Explotación, Redes y Fuerza Bruta
* **`metasploit-framework`**: Plataforma de referencia global para pruebas de penetración y explotación de vulnerabilidades.
* **`bettercap` / `aircrack-ng`**: Frameworks avanzados para auditoría de redes inalámbricas (WiFi), ataques MitM y sniffer de paquetes.
* **`beef` (Browser Exploitation Framework)**: Herramienta de auditoría enfocada en vectores de ataque del lado del cliente web.
* **`hydra-gtk` / `johntheripper` / `hashcat`**: Suites ultra-veloces de cracking de contraseñas y fuerza bruta a protocolos.
* **`sqlmap` / `dirb` / `vulnx`**: Automatización de detección de inyecciones SQL y escaneo de vulnerabilidades en CMS.
* **`evilginx2` / `lockphish` / `nexphisher`**: Frameworks de simulación de vectores de Phishing avanzado y bypass de 2FA.

### E. Entorno, Visualización y Utilidades del Sistema
* **`fzf`**: Buscador interactivo difuso para agilizar el uso de menús táctiles en Termux.
* **`glow` / `markdown-viewer`**: Renderizadores estéticos de manuales Markdown en la terminal.
* **`traductor` / `translate-shell`**: Herramientas integradas para traducir documentación técnica en tiempo real.
* **`tmux` / `neovim` / `vim`**: Multiplicadores de terminal y entornos de edición de código altamente personalizables.
* **`cloudflared` / `ngrok` / `localtunnel`**: Exposición segura de servidores locales a internet mediante túneles de red.
* **`qemufy` (`termux-docker-qemu.md`) / `udocker`**: Entornos para virtualización y emulación de contenedores docker en espacio de usuario.
* **`engram`**: Motor persistente de gestión de memoria y aprendizaje continuo del proyecto.

---

## 🔑 3. Configuración del Entorno y Claves de API

La suite i-HakLab incluye un sistema de gestión del entorno de ejecución y de credenciales de servicios externos.

### El archivo `envvariables`
Ubicado en `~/.local/etc/i-Haklab/envvariables`, este archivo es cargado por la shell al inicio y define todas las variables de entorno del ecosistema:
* **Inyección de Wrappers en el `$PATH`**: Añade `~/.local/bin/` al inicio del `PATH` para que los interceptores de `apt`, `npm` y `pnpm` de la suite tengan precedencia sobre los binarios nativos de Termux.
* **Compiladores del Sistema**: Establece `clang`/`clang++` como compiladores, configura el NDK de Android, rutas de `JAVA_HOME`, `GOPATH`, `GOROOT`, y los flags de compilación necesarios.
* **Entorno Gráfico**: Declara `DISPLAY=:0` para Termux-X11 y Xwayland.
* **Aliases de Productividad**: Define alias de consola como `bat` (con tema Visual Studio Dark+), `df` (con `duf`), y atajos de `ls`.

### El Comando `i-HakLab setapikey`
Gestor interactivo para configurar las claves de acceso de servicios externos de IA y OSINT. Al ejecutarlo se muestra un menú numerado que permite seleccionar la plataforma de destino:

| Plataforma | Proveedor | Dónde Obtener la Clave |
| :--- | :--- | :--- |
| `chatGPT` | OpenAI | https://platform.openai.com/account/api-keys |
| `claude` | Anthropic | https://platform.claude.com |
| `deepseek` | DeepSeek | https://api-docs.deepseek.com/ |
| `gemini` | Google AI Studio | https://aistudio.google.com |
| `mistralAI` | Mistral AI | https://console.mistral.ai |
| `neural` | Neural (suite) | — |
| `phonescan` | Numverify | https://numverify.com/dashboard |

Las claves se persisten directamente en `~/.local/etc/i-Haklab/variables` con el formato `APIKEY_<plataforma>` y son protegidas con confirmación interactiva antes de sobrescribirse. Para más detalles, consulta la guía completa de [Variables de Entorno y API Keys](../termux/variables-y-api-keys.md).

