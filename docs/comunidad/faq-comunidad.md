# Preguntas Frecuentes de la Comunidad (FAQ) 👥

Aquí recopilamos las dudas generales sobre la comunidad **Ivam3bycinderella**, el soporte de las herramientas y la filosofía de desarrollo. Para preguntas puramente técnicas de la terminal, consulta el [FAQ de Termux](../termux/paquetes.md).

### ¿Quién mantiene el proyecto i-HakLab?
El proyecto es conceptualizado, programado y mantenido por **Ivam3**, con el apoyo y retroalimentación constante de la comunidad "Ivam3bycinderella". 

### ¿Dónde puedo ver las guías en video?
Todo el material audiovisual explicativo, demostraciones de herramientas en tiempo real y actualizaciones del laboratorio se publican de forma oficial en el canal de **YouTube [Ivam3bycinderella]**.

### ¿Cómo puedo reportar un fallo en las herramientas de i-HakLab?
Si encuentras un error en la suite interactiva de comandos (por ejemplo en el instalador, los scripts de traducción, o los módulos de IA), debes reportarlo abriendo un *Issue* en el repositorio de GitHub correspondiente o notificándolo de forma estructurada en el grupo de soporte de Telegram, adjuntando los logs de error del terminal.

### ¿Se aceptan sugerencias para nuevas herramientas?
¡Por supuesto! El ecosistema i-HakLab evoluciona gracias a las necesidades del mundo real de la comunidad. Herramientas y módulos recientes como `qemufy` (para virtualización ligera) o `androforensic` (para análisis forense en dispositivos móviles) surgieron de la retroalimentación técnica interna. Las sugerencias deben plantearse detallando el caso de uso y los beneficios colectivos.

### ¿Por qué cambiaron algunas funciones en la versión v3.12?
El desarrollo en entornos Android es altamente dinámico. Varias opciones y comandos antiguos (como `chatGPT` o menús obsoletos de guías rápidas `QG`) fueron reemplazados o consolidados en comandos más potentes y mantenibles (como `chatAI`) para evitar la obsolescencia provocada por los cambios en las APIs de proveedores externos y las restricciones de seguridad internas del sistema operativo Android.

### ¿Qué material educativo gratuito proporciona la comunidad y cómo puedo acceder a él?
La comunidad proporciona video cursos de programación, un arsenal de libros técnicos y retos CTF locales (LAN). Puedes acceder a ellos de las siguientes formas:
1. Desde la suite de terminal ejecutando los comandos `i-HakLab show tutorials` y `i-HakLab show books`.
2. Desde Telegram, interactuando con [@Ivam3_bot](https://t.me/ivam3_bot).
Para más detalles, consulta la guía de [Material Educativo](./materiales-y-membresia.md).

### ¿Qué es la membresía SUDOERS y cuáles son sus beneficios?
**SUDOERS** es nuestra membresía VIP de soporte y formación técnica avanzada. Ofrece acceso a:
* Video tutoriales detallados paso a paso sobre procesos de hacking y resolución de retos de Hack The Box desde Termux.
* Un canal privado de Telegram con todo el contenido disponible para su fácil descarga y reproducción en segundo plano.
* Contacto directo con **Ivam3** para asesorías y soporte personalizado.
Puedes unirte a través de [YouTube](https://www.youtube.com/@ivam3bycinderella/join) o directamente en el bot [@Ivam3_bot](https://t.me/ivam3_bot). Consulta todos los detalles en la página de [Membresía SUDOERS](./materiales-y-membresia.md).

### ¿Cómo configuro las claves de API para usar los módulos de IA de i-HakLab?
Ejecuta el comando interactivo de la suite:
```bash
i-HakLab setapikey
```
Se mostrará un menú que permite seleccionar el proveedor (OpenAI, Claude, Gemini, DeepSeek, MistralAI, etc.) e introducir la llave de forma segura. La clave se guarda de forma persistente en `~/.local/etc/i-Haklab/variables` con el formato `APIKEY_<plataforma>`. Para más detalles, consulta la guía de [Variables de Entorno y API Keys](../termux/variables-y-api-keys.md).

### ¿Por qué al instalar una herramienta con `apt` me dice que debo usar `pip` o `npm`?
i-HakLab instala interceptores invisibles (wrappers) sobre los comandos `apt` y `npm` para detectar automáticamente si el paquete que intentas instalar pertenece al ecosistema de Python, Node.js o Ruby, y redirigirte al gestor de paquetes correcto con la configuración adecuada para Android. Esto evita errores de instalación en Termux. Consulta la guía de [Gestión de Paquetes](../termux/paquetes.md) para entender el flujo completo.

### ¿Qué es `qemufy` y cómo se diferencia de `termux-docker-qemu`?
Son dos herramientas distintas con objetivos completamente diferentes:
* **`qemufy`**: Convierte imágenes de máquinas virtuales de plataformas de retos CTF (como [TheHackersLabs](https://thehackerslabs.com/)) desde formatos VMware (`.vmdk`) o VirtualBox (`.ova`) al formato QEMU compatible (`.qcow2`) para poder resolverlos directamente desde Termux en Android.
* **`termux-docker-qemu`**: Levanta una máquina virtual de Alpine Linux optimizada para ejecutar el daemon de **Docker** dentro de Termux, con puertos de red predefinidos y un volumen compartido (`termux2alpine`) para el intercambio de archivos.

### ¿Cómo puedo resolver retos CTF de TheHackersLabs desde mi celular?
1. Descarga la imagen de la máquina vulnerable en formato `.vmdk` o `.ova` desde la plataforma.
2. Usa **`qemufy`** para convertir la imagen al formato `.qcow2`.
3. Inicia la máquina virtual en Termux con QEMU.
4. Usa las herramientas de la suite (nmap, metasploit, etc.) para encontrar y explotar las vulnerabilidades.
Para acceder a video tutoriales con la resolución paso a paso de estas máquinas desde Termux, consulta la sección de [Membresía SUDOERS](./materiales-y-membresia.md).


