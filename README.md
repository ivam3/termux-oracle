# Termux Oracle 🧙‍♂️
**The ultimate source of knowledge about Termux, Linux on Android, and automation.**

This repository hosts the official [i-HakLab](https://ivam3.github.io) documentation structured as a **technical brain** for Artificial Intelligence assistants (like Antigravity and DevinAI from [DeepWiki](https://deepwiki.com/)). Its purpose is to serve as an oracle to bypass Android limitations, compile complex tools (glibc, Node, Python), and automate full development environments.

---

## 🗺️ Navigation Portal
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/ivam3/termux-oracle)

### 👥 [1. Community](./docs/comunidad/faq-comunidad.md)
Discover the fundamental pillars, history, rules, and mission behind our technical movement.
* [Project History](./docs/comunidad/historia.md)
* [Mission and Vision](./docs/comunidad/mision.md)
* [Rules of Conduct](./docs/comunidad/reglas.md)
* [Community Frequently Asked Questions](./docs/comunidad/faq-comunidad.md)
* [Educational Material and SUDOERS Membership](./docs/comunidad/materiales-y-membresia.md)


### 📱 [2. Termux Core](./docs/termux/instalacion.md)
Advanced configuration guides, package management, and Linux environment on Android.
* [Installation Guide](./docs/termux/instalacion.md)
* [Initial Configuration](./docs/termux/configuracion.md)
* [Package Management (`pkg` vs `apt`) and `apt`/`npm`/`pnpm` wrappers](./docs/termux/paquetes.md)
* [🛠️ 'fixer' Wrapper and Automation](./docs/termux/fixer.md)
* [🖥️ Graphical Interface with Termux-X11](./docs/termux/termux-x11.md)
* [Storage Access](./docs/termux/almacenamiento.md)
* [SSH Server](./docs/termux/ssh.md)
* [Version Control with Git](./docs/termux/git.md)
* [Python Environment](./docs/termux/python.md)
* [Environment Variables and API Keys Configuration](./docs/termux/variables-y-api-keys.md)
* [🛠️ Glibc Binaries Adaptation (`claude-code`, `opencode`)](./docs/termux/compilacion-glibc.md)
* [🤖 AI Agent Ecosystem, Shared Config and MCP](./docs/../.agents/skills/termux-oracle/references/agent-ecosystem.md)
* [🔥 Troubleshooting](./docs/termux/troubleshooting.md)


### 🤖 [3. Technical Android](./docs/android/adb.md)
Low-level interaction, debugging, and essential tools for enthusiasts and developers.
* [Introduction to ADB (Android Debug Bridge)](./docs/android/adb.md)
* [Wireless Debugging](./docs/android/wireless-debugging.md)
* [Flashing and Fastboot](./docs/android/fastboot.md)
* [Android Security Fundamentals](./docs/android/seguridad.md)
* [🔓 Bypassing Limitations without Root](./docs/android/bypass-limitaciones.md)

### 🎯 [4. Learning Paths & Laboratories](./docs/laboratorios/principiante.md)
Follow a structured path from essential Linux commands to advanced security auditing.
* [Level 0: Beginner (Linux Base)](./docs/laboratorios/principiante.md)
* [Level 1: Intermediate (Development Environment)](./docs/laboratorios/intermedio.md)
* [Level 2: Advanced (Automation and Networking)](./docs/laboratorios/avanzado.md)

### 🏴‍☠️ [5. CTF (Capture The Flag)](./docs/ctf/recursos.md)
Challenge resolution guides, classic security labs, and methodologies.
* [OverTheWire: Bandit](./docs/ctf/bandit.md)
* [OverTheWire: Leviathan](./docs/ctf/leviathan.md)
* [CTF Resources and Platforms](./docs/ctf/recursos.md)

### 📜 [6. Scripts & Automation](./docs/scripts/bash.md)
Maximize your terminal's potential by using scripts and native APIs.
* [Bash Scripting](./docs/scripts/bash.md)
* [Hardware Interaction via Termux-API](./docs/scripts/termux-api.md)
* [Automation Projects](./docs/scripts/automatizacion.md)

### 📖 [7. Glossary & Resources](./docs/glosario/conceptos.md)
Dictionary of technical concepts and useful tool collections.
* [i-HakLab User Manual and Tool Arsenal](./docs/recursos/herramientas-ihaklab.md)
  * Includes `apt`/`npm`/`pnpm` wrappers reference, `pkg2conf`, default credentials, and `4share`/`servers4test` automations.
* [i-HakLab Tool Ecosystem](./docs/recursos/herramientas.md)
* [Detailed Arsenal Manuals (Over 180 tools)](./docs/recursos/herramientas/README.md)
* [Termux-Packages: repository of adapted tools for Android](./docs/recursos/termux-packages.md)
* [Key Environment Concepts](./docs/glosario/conceptos.md)
* [Useful Links and Recommended Tools](./docs/recursos/enlaces.md)


---

## 🤖 AI Agent Skill (OpenCode, Claude Code, Cline)

This documentation is also available as a **skill** for AI agents, allowing OpenCode, Claude Code, Cline, and other agents to understand the Termux/Android environment, configure i-HakLab, and know the 190+ tools in the arsenal.

### Installation

**Requirement:** have the `ivam3/termux-packages` repository added.

```bash
apt install termux-oracle-skill
```

This downloads and installs the skill in `~/.agents/skills/termux-oracle/`, ready to be used by compatible agents.

> The skill is published in [`.agents/skills/termux-oracle/`](./.agents/skills/termux-oracle/) for anyone who prefers to review its content or install it manually.

---

## 💡 How to interact with DevinAI on this Wiki?

This documentation has been semantically optimized. You can ask complex questions to the assistant via the [DevinAI](https://deepwiki.com/ivam3/termux-oracle) button on the [Telegram bot](https://t.me/ivam3_bot), such as:
* *"How do I fix the CANNOT LINK EXECUTABLE error in Termux?"*
* *"What is the difference between pkg and apt in i-HakLab?"*
* *"How do the apt, npm, and pnpm wrappers work in i-HakLab?"*
* *"What is the default i-HakLab password and how do 4share and servers4test work?"*
* *"Which learning path should I follow if I already know basic Linux commands?"*

---
Official Channels: [Telegram](https://t.me/Ivam3bycinderella) | [YouTube](https://youtube.com/@Ivam3bycinderella) | [GitHub](https://github.com/ivam3)
