# Hermes Agent (hermes-agent)

## ¿Qué es Hermes Agent?

**Hermes Agent** es un agente de IA personal de código abierto creado por **Nous Research**. Ejecuta el mismo núcleo de agente a través de CLI, TUI (Ink/React), escritorio (Electron), y una pasarela de mensajería compatible con Telegram, Discord, Slack, WhatsApp, Signal, Matrix, Mattermost, Email, SMS, y más de 20 plataformas adicionales. Está escrito principalmente en Python y TypeScript, y se extiende mediante plugins, habilidades (skills), y servidores MCP.

## ¿Para qué es útil la herramienta?

*   **Asistente Persistente Multi-Plataforma:** Un solo agente que te acompaña en la terminal, en el escritorio, y en todas tus aplicaciones de mensajería, manteniendo el contexto entre plataformas.
*   **Memoria a Largo Plazo:** Aprende de interacciones pasadas mediante proveedores de memoria intercambiables (Engram, Honcho, Mem0, SuperMemory, etc.).
*   **Habilidades Auto-Gestionadas:** El agente puede crear, refinar y archivar sus propias habilidades (skills) mediante un sistema de curador automático, adaptándose a las necesidades del usuario sin intervención manual.
*   **Delegación y Trabajo en Paralelo:** Puede lanzar subagentes para tareas específicas (orquestador) o procesos paralelos (batch), cada uno con su propio contexto y herramientas.
*   **Automatización de Terminal y Navegador:** Ejecuta comandos reales en la terminal y controla navegadores web (Chromium vía Playwright) para automatizar flujos complejos.
*   **Tareas Programadas:** El sistema de cron integrado permite ejecutar consultas, scripts o informes de forma periódica sin intervención.
*   **Dashboard Web:** Incluye una interfaz web que incrusta la TUI real mediante PTY + WebSocket, ofreciendo acceso remoto al agente desde cualquier navegador.

## Instalación

Hermes Agent se distribuye en Termux como paquete `.deb` desde el repositorio **ivam3/termux-packages**:

```bash
pkg install hermes
```

### Proceso de post-instalación

El paquete ejecuta un `postinst` que realiza automáticamente:

1. **Clonado del repositorio** en `~/.hermes/hermes-agent/` (rama `main`, depth 1)
2. **Entorno virtual Python** (`python -m venv venv`) con pip actualizado
3. **Instalación de dependencias Python** usando `pip install -e '.[termux-all]' -c constraints-termux.txt`
   - `psutil` y `cryptography` se toman del sistema (`python-psutil`, `python-cryptography`) — pip los salta automáticamente
   - Perfil `termux-all` = `[all]` sin `matrix`, `rl` y otros extras problemáticos en Android
   - Fallback: `.[termux]` → `.` (core)
4. **Dependencias Node.js** con `npm install` para herramientas de navegador y TUI
5. **Configuración inicial** en `~/.hermes/` (`.env`, `config.yaml`, `SOUL.md`)
6. **Sincronización de skills** incluidos desde el repositorio
7. El comando `hermes` queda disponible en `$PREFIX/bin/hermes` mediante un shim que resuelve el entry point del venv en tiempo de ejecución

### Dependencias del paquete

El manifiesto del paquete declara todas las dependencias necesarias, que se instalan automáticamente:

```
python, nodejs-lts, python-pip, python-psutil, python-cryptography,
clang, rust, make, pkg-config, libffi, openssl, ca-certificates, curl,
git, ripgrep, ffmpeg, playwright-proot, termux-api
```

### Diferencias con instalación en Linux/macOS

| Aspecto | Termux | Linux/macOS |
|---------|--------|-------------|
| **Gestor Python** | stdlib venv + pip | `uv` (gestor de paquetes Python) |
| **psutil** | `python-psutil` (pkg) — evita compilación fallida en Android | Compilado desde source |
| **cryptography** | `python-cryptography` (pkg) — evita compilación Rust | Compilado desde source |
| **Navegador** | `playwright-proot` (proot + Chromium) | Playwright nativo + system deps |
| **Node.js** | `nodejs-lts` (pkg) | Tarball descargado a `~/.hermes/node/` |
| **Desktop** | No disponible (Electron no corre en Termux) | App nativa vía Electron |
| **Gateway service** | `nohup` en segundo plano | systemd / launchd |

## ¿Cómo se usa? (Ejemplos básicos)

**Ejemplo 1: Iniciar chat interactivo**

```bash
hermes
```

**Ejemplo 2: Configurar proveedores de IA**

```bash
hermes setup
```

**Ejemplo 3: Iniciar gateway de mensajería**

```bash
hermes gateway --verbose
```

**Ejemplo 4: Actualizar a la última versión**

```bash
hermes update
```

## Consideraciones Adicionales

*   **API Keys:** Requiere al menos una API key de algún proveedor de IA (OpenAI, Anthropic, Google Gemini, Groq, etc.) configurada en `~/.hermes/.env` o mediante `hermes setup`.
*   **Memoria:** Engram es el proveedor de memoria por defecto y se instala como parte de las dependencias del paquete. Para otros proveedores (Honcho, Mem0, etc.), consulta la documentación oficial.
*   **Playwright en Termux:** El paquete `playwright-proot` permite ejecutar Chromium headless dentro de un entorno proot Ubuntu, necesario para las herramientas de navegador de Hermes.
*   **Perfiles:** Usa `hermes -p <nombre>` para crear perfiles independientes con su propia configuración, memoria y sesiones. Cada perfil tiene su propio `HERMES_HOME`.
*   **Compatibilidad:** Hermes Agent sigue el estándar abierto de skills, por lo que cualquier skill diseñada para el ecosistema (incluyendo `termux-oracle-skill`) funciona sin modificaciones.

---

*Nota: Esta herramienta proporciona un asistente de IA persistente y multiplataforma para el ecosistema Termux y i-Haklab, integrando memoria, habilidades y automatización en un solo agente.*
