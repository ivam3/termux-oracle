# Conceptos Clave del Entorno (Glosario Técnico) 📖🧠

Este glosario define los términos, herramientas, comandos y tecnologías fundamentales utilizados dentro del ecosistema de **i-HakLab** e **Ivam3bycinderella**. Está diseñado para homogeneizar el conocimiento y servir como base de referencia conceptual para la comunidad y asistentes de Inteligencia Artificial.

---

## 📱 Entorno Termux & Android

### **Termux**
Una aplicación de emulación de terminal para Android que proporciona un entorno Linux completo en espacio de usuario. No requiere root para funcionar y permite instalar paquetes de software utilizando gestores de paquetes.

### **i-HakLab**
Suite de productividad técnica y automatización de seguridad interactiva desarrollada por la comunidad. Centraliza herramientas de IA, redes, automatización y OSINT en menús interactivos de consola para Termux.

### **chatAI**
Módulo conversacional de inteligencia artificial integrado en la consola de **i-HakLab** que reemplaza al antiguo comando `chatGPT` desde la versión v3.12, ofreciendo soporte de modelos multilínea, análisis de errores y conectividad flexible.

### **fixer**
Script de automatización interno y wrapper de i-HakLab diseñado para reparar fallos comunes de dependencias, enlaces simbólicos dañados, problemas de red y configuraciones corruptas en el entorno Termux de manera automática.

### **Scoped Storage**
Modelo de almacenamiento introducido a partir de Android 10/11 que aísla el acceso al disco de las aplicaciones. Impide que las apps lean los archivos directos de otras y restringe el acceso general a carpetas compartidas del sistema como `/sdcard/Android/data`.

---

## 🛠️ Herramientas de Desarrollo y Gestión de Paquetes

### **APT (Advanced Packaging Tool)**
Gestor de paquetes clásico heredado de distribuciones Linux como Debian y Ubuntu. Administra la instalación, actualización y remoción de software manejando automáticamente las dependencias.

### **PKG**
Un wrapper (envoltura) simplificado de Termux sobre `apt` que realiza automáticamente actualizaciones de repositorios internas previas a la instalación de paquetes para asegurar la compatibilidad y consistencia del software.

### **Git**
Sistema de control de versiones distribuido de código abierto. Permite registrar cambios en archivos y coordinar el trabajo en proyectos de software a través de repositorios como GitHub o GitLab.

### **SSH (Secure Shell)**
Protocolo criptográfico seguro para operar servicios de red de forma segura sobre una red insegura. Permite conectarse a la terminal de Termux de manera remota y segura desde una computadora u otro móvil.

---

## 🤖 Administración de Sistemas y Depuración de Android

### **ADB (Android Debug Bridge)**
Herramienta de depuración y enlace que permite a desarrolladores y técnicos interactuar con el sistema operativo de un dispositivo Android desde una consola para instalar apps, ejecutar comandos de shell de bajo nivel o depurar el sistema.

### **Fastboot**
Protocolo de diagnóstico y herramienta de consola utilizado para comunicarse con el hardware de Android a bajo nivel (cuando se encuentra en modo Bootloader) para flashear particiones, cambiar ROMs o desbloquear el cargador de arranque.

### **Bootloader**
El cargador de arranque. Es el primer programa que se ejecuta al encender el dispositivo y decide si cargar el recovery de Android, el modo Fastboot, o arrancar el kernel del sistema operativo normal.

### **Root (Superusuario)**
El usuario administrador del sistema en entornos Unix/Linux (UID 0) que posee permisos ilimitados sobre el sistema de archivos y los procesos de hardware. En Android, obtener root requiere vulnerar el sistema de fábrica mediante herramientas como Magisk o KernelSU.

### **PRoot**
Implementación en espacio de usuario de `chroot`, `mount --bind` y `binfmt_misc`. Permite simular una estructura de directorios Linux tradicional (con rutas `/usr/bin`, `/lib`, etc.) e instalar otras distribuciones de Linux completas (como Ubuntu o Arch) dentro de Termux sin necesidad de tener acceso Root.

### **SELinux / SEAndroid (Security-Enhanced Linux)**
Mecanismo de seguridad de control de acceso obligatorio integrado en el kernel de Android. Define políticas extremadamente rígidas para aislar procesos, servicios y usuarios, impidiendo operaciones inseguras incluso si un proceso se ejecuta con permisos de superusuario (Root).

---

## 🔑 Gestión del Entorno e Inteligencia Artificial

### **envvariables**
Archivo de configuración de Bash ubicado en `~/.local/etc/i-Haklab/envvariables` que declara y exporta todas las variables de entorno fundamentales de la suite i-HakLab. Incluye rutas de compiladores, JDK, Go, NDK de Android y la inyección prioritaria de `~/.local/bin/` al `$PATH` para que los wrappers de `apt` y `npm` de la suite intercepcen los comandos del sistema.

### **setapikey** (`i-HakLab setapikey`)
Comando interactivo de la suite i-HakLab para registrar y persistir claves de API de proveedores externos de inteligencia artificial y servicios OSINT. Soporta la configuración de llaves para: OpenAI (`chatGPT`), Anthropic (`claude`), DeepSeek, Google (`gemini`), MistralAI, Neural y Numverify (`phonescan`). Las claves se almacenan directamente en el archivo `~/.local/etc/i-Haklab/variables` mediante sustitución automática con `sed`.

### **pkg2conf**
Motor de orquestación de post-instalación de i-HakLab (`~/.local/libexec/pkg2conf`). Se invoca automáticamente por los wrappers de `apt` y `npm` tras instalar un paquete, y ejecuta parches de código fuente, creación de enlaces simbólicos de configuración, arranque de servicios y configuraciones desatendidas específicas para cada herramienta.

### **APIKEY_\<plataforma\>**
Formato de variable de entorno utilizado por la suite para almacenar claves de acceso a APIs de forma nombrada (ej: `APIKEY_gemini`, `APIKEY_claude`, `APIKEY_chatGPT`). Son leídas automáticamente por módulos internos como `chatAI` o `phonescan` al iniciarse para autenticarse con sus respectivos servicios en la nube.

---

## 🏴‍☠️ Conceptos de Ciberseguridad y CTF

### **CTF (Capture The Flag)**
Competición o ejercicio práctico de seguridad informática donde los participantes deben explotar vulnerabilidades en sistemas diseñados específicamente para ello, con el fin de encontrar una "bandera" (texto secreto) que demuestra el éxito del ataque. En la comunidad Ivam3bycinderella se realizan retos CTF locales en LAN y se resuelven retos de plataformas como Hack The Box directamente desde Termux.

### **TheHackersLabs**
Plataforma de retos de hacking ético y ciberseguridad que distribuye máquinas virtuales vulnerables en formatos de VMware (`.vmdk`) y VirtualBox (`.ova`). Los retos se resuelven comprometiendo la máquina virtual objetivo, que corre en una red local (LAN).

### **qemufy**
Herramienta creada por Ivam3 para convertir imágenes de máquinas virtuales de VMware (`.vmdk`) o VirtualBox (`.ova`) al formato QEMU compatible (`.qcow2`) y correrlas directamente en Termux. Su objetivo principal es permitir resolver retos CTF de plataformas como TheHackersLabs desde un dispositivo Android sin necesidad de una computadora.

### **OSINT (Open Source Intelligence)**
Metodología de inteligencia que consiste en la recolección y análisis de información de fuentes públicas y abiertas. En el contexto de i-HakLab, herramientas como `sherlock`, `holehe`, `ghunt`, `osintgram`, `shodan` y `phonescan` automatizan la recolección de inteligencia sobre personas, organizaciones o infraestructura.

### **Pentesting (Penetration Testing)**
Proceso autorizado y planificado de evaluación de la seguridad de un sistema informático mediante la simulación controlada de ataques reales. Permite identificar vulnerabilidades antes de que sean explotadas por actores maliciosos. Las herramientas de la suite i-HakLab están diseñadas para su uso en entornos propios o en plataformas de práctica ética como Hack The Box o TryHackMe.

### **SUID (Set User ID)**
Permiso especial de Linux que al estar activo en un ejecutable, hace que el programa se ejecute con los privilegios del propietario del archivo (en lugar del usuario que lo lanza). Es un vector común de escalada de privilegios en retos CTF de Linux cuando está mal configurado.

---

## 🌐 Redes y Tunelización

### **VirtFS / 9P (Plan 9 File System)**
Protocolo de sistema de archivos en red utilizado por QEMU para compartir directorios del host (Termux) con la máquina virtual guest (Alpine Linux). En `termux-docker-qemu`, el volumen `termux2alpine` se monta mediante este mecanismo, permitiendo el intercambio directo de archivos entre ambos entornos sin usar SSH.

### **cloudflared / ngrok / localtunnel**
Herramientas de tunelización que crean un puente de red cifrado entre un servidor local (corriendo en Termux) y un subdominio accesible públicamente desde internet. Útiles para exponer APIs, servidores web, o paneles de administración sin necesitar una IP pública ni abrir puertos en el router.

### **Proxychains-ng**
Herramienta de interceptación de red que redirige el tráfico de cualquier comando de consola a través de cadenas de proxies (HTTP, SOCKS4 o SOCKS5). Se integra frecuentemente con Tor (`127.0.0.1:9050`) en i-HakLab para anonimizar el tráfico de herramientas de reconocimiento.

