# i-HakLab Knowledge Base 🚀
¡Bienvenido al centro de documentación técnica oficial de **i-HakLab** e **Ivam3bycinderella**! Esta base de conocimientos está diseñada y estructurada específicamente para servir como el núcleo de información técnica sobre Termux, Linux en Android, Automatización, Desarrollo y Seguridad Informática, sirviendo de soporte directo a la comunidad [Ivam3byCinderella](https://ivam3.github.io) a través de asistentes de Inteligencia Artificial (como DevinAI de [DeepWiki](https://deepwiki.com/)).

---

## 🗺️ Portal de Navegación
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/ivam3/termux-oracle)

### 👥 [1. Comunidad](./docs/comunidad/faq-comunidad.md)
Descubre los pilares fundamentales, historia, normas y la misión detrás de nuestro movimiento técnico.
* [Historia del Proyecto](./docs/comunidad/historia.md)
* [Misión y Visión](./docs/comunidad/mision.md)
* [Reglas de Convivencia](./docs/comunidad/reglas.md)
* [Preguntas Frecuentes de la Comunidad](./docs/comunidad/faq-comunidad.md)
* [Material Educativo y Membresía SUDOERS](./docs/comunidad/materiales-y-membresia.md)


### 📱 [2. Termux Core](./docs/termux/instalacion.md)
Guías de configuración avanzada, gestión de paquetes y entorno Linux en Android.
* [Guía de Instalación](./docs/termux/instalacion.md)
* [Configuración Inicial](./docs/termux/configuracion.md)
* [Gestión de Paquetes (`pkg` vs `apt`) y wrappers `apt`/`npm`/`pnpm`](./docs/termux/paquetes.md)
* [🛠️ Wrapper 'fixer' y Automatización](./docs/termux/fixer.md)
* [🖥️ Interfaz Gráfica con Termux-X11](./docs/termux/termux-x11.md)
* [Acceso al Almacenamiento](./docs/termux/almacenamiento.md)
* [Servidor SSH](./docs/termux/ssh.md)
* [Control de Versiones con Git](./docs/termux/git.md)
* [Entorno Python](./docs/termux/python.md)
* [Variables de Entorno y Configuración de API Keys](./docs/termux/variables-y-api-keys.md)
* [🛠️ Adaptación de Binarios Glibc (`claude-code`, `opencode`)](./docs/termux/compilacion-glibc.md)
* [🔥 Solución de Problemas (Troubleshooting)](./docs/termux/troubleshooting.md)


### 🤖 [3. Android Técnico](./docs/android/adb.md)
Interacción a bajo nivel, depuración y herramientas esenciales para entusiastas y desarrolladores.
* [Introducción a ADB (Android Debug Bridge)](./docs/android/adb.md)
* [Depuración Inalámbrica (Wireless Debugging)](./docs/android/wireless-debugging.md)
* [Flasheo y Fastboot](./docs/android/fastboot.md)
* [Fundamentos de Seguridad en Android](./docs/android/seguridad.md)
* [🔓 Bypass de Limitaciones sin Root](./docs/android/bypass-limitaciones.md)

### 🎯 [4. Rutas de Aprendizaje & Laboratorios](./docs/laboratorios/principiante.md)
Sigue un camino estructurado desde los comandos esenciales de Linux hasta la auditoría de seguridad avanzada.
* [Nivel 0: Principiante (Linux Base)](./docs/laboratorios/principiante.md)
* [Nivel 1: Intermedio (Entorno de Desarrollo)](./docs/laboratorios/intermedio.md)
* [Nivel 2: Avanzado (Automatización y Redes)](./docs/laboratorios/avanzado.md)

### 🏴‍☠️ [5. CTF (Capture The Flag)](./docs/ctf/recursos.md)
Guías de resolución de retos, laboratorios clásicos de seguridad y metodologías.
* [OverTheWire: Bandit](./docs/ctf/bandit.md)
* [OverTheWire: Leviathan](./docs/ctf/leviathan.md)
* [Recursos y Plataformas CTF](./docs/ctf/recursos.md)

### 📜 [6. Scripts & Automatización](./docs/scripts/bash.md)
Aprovecha al máximo el potencial de tu terminal mediante el uso de scripts y APIs nativas.
* [Scripting en Bash](./docs/scripts/bash.md)
* [Interacción con Hardware vía Termux-API](./docs/scripts/termux-api.md)
* [Proyectos de Automatización](./docs/scripts/automatizacion.md)

### 📖 [7. Glosario & Recursos](./docs/glosario/conceptos.md)
Diccionario de conceptos técnicos y colecciones de herramientas útiles.
* [Manual de Uso de i-HakLab y Arsenal de Herramientas](./docs/recursos/herramientas-ihaklab.md)
  * Incluye referencia de wrappers `apt`/`npm`/`pnpm`, `pkg2conf`, credenciales por defecto y automatizaciones de `4share` y `servers4test`.
* [Ecosistema de Herramientas de i-HakLab](./docs/recursos/herramientas.md)
* [Manuales Detallados del Arsenal (Más de 180 herramientas)](./docs/recursos/herramientas/README.md)
* [Termux-Packages: repositorio de herramientas adaptadas para Android](./docs/recursos/termux-packages.md)
* [Conceptos Clave del Entorno](./docs/glosario/conceptos.md)
* [Enlaces de Interés y Herramientas recomendadas](./docs/recursos/enlaces.md)


---

## 🤖 Skill para Agentes de IA (OpenCode, Claude Code, Cline)

Esta documentación también está disponible como **skill** para agentes de IA, permitiendo que OpenCode, Claude Code, Cline y otros agentes comprendan el entorno Termux/Android, sepan configurar i-HakLab y conozcan las 190+ herramientas del arsenal.

### Instalación

**Requisito:** tener el repositorio `ivam3/termux-packages` agregado.

```bash
apt install termux-oracle-skill
```

Esto descarga e instala la skill en `~/.agents/skills/termux-oracle/`, lista para ser usada por agentes compatibles.

> La skill se encuentra publicada en [`.agents/skills/termux-oracle/`](./.agents/skills/termux-oracle/) para quien prefiera revisar su contenido o instalarla manualmente.

---

## 💡 ¿Cómo interactuar con DevinAI en esta Wiki?

Esta documentación ha sido optimizada semánticamente. Puedes hacerle preguntas complejas al asistente en el boton [DevinAI](https://deepwiki.com/ivam3/termux-oracle) del [bot de Telegram](https://t.me/ivam3_bot), tales como:
* *"¿Cómo soluciono el error CANNOT LINK EXECUTABLE en Termux?"*
* *"¿Cuál es la diferencia entre pkg y apt en i-HakLab?"*
* *"¿Cómo funcionan los wrappers apt, npm y pnpm de i-HakLab?"*
* *"¿Cuál es la contraseña por defecto de i-HakLab y cómo funcionan 4share y servers4test?"*
* *"¿Qué ruta de aprendizaje debo seguir si ya conozco los comandos básicos de Linux?"*

---
Canales Oficiales: [Telegram](https://t.me/Ivam3bycinderella) | [YouTube](https://youtube.com/@Ivam3bycinderella) | [GitHub](https://github.com/ivam3)
