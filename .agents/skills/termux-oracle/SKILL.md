---
name: termux-oracle
description: >
  Conocimiento experto sobre Termux (Linux en Android), i-HakLab y sus más de 190 herramientas.
  El agente usa esta skill para comprender el entorno Android/Termux, configurar i-HakLab,
  instalar herramientas correctamente (apt/pip/npm/gem/glibc), resolver limitaciones de Android
  (Bionic vs glibc, proot, root) y guiar al usuario en el uso del ecosistema.
allowed-tools:
  - Bash(read:termux-oracle/*, detect-env, apt, pkg, i-Haklab, pip, npm)
  - Read
  - Glob
  - Grep
  - WebSearch
  - WebFetch
---

# Termux-Oracle Skill

Contexto completo del ecosistema Termux/Android/i-HakLab para agentes de IA.

## 1. Detección del entorno

Al iniciar, ejecuta `scripts/detect-env.sh` para conocer el entorno actual:

```bash
bash ~/.agents/skills/termux-oracle/scripts/detect-env.sh
```

Esto retorna JSON con: `termux_native`, `proot_distro`, `ssh`, `ihaklab_installed`, `wrapper_apt`, `glibc_repo`, `arch`.

## 2. Contexto del entorno

### Android + Termux
- Android usa **Bionic libc** (no GNU glibc). Los binarios Linux precompilados no funcionan sin adaptación.
- Termux corre como app de usuario **sin root** por defecto.
- `$PREFIX` = `/data/data/com.termux/files/usr`
- El gestor de paquetes es `pkg` (wrapper de `apt` con auto-refresh de repos).
- **REGLAS**:
  - Usa `pkg install` para instalaciones individuales (evita errores 404).
  - `apt update && apt upgrade` solo para mantenimiento general.
  - NO mezcles fuentes de instalación de apps Termux (GitHub/F-Droid/Play Store).

### i-HakLab
- Suite que convierte Termux en un laboratorio portátil de ciberseguridad, desarrollo y automatización.
- Instala **wrappers** en `~/.local/bin/` (apt, npm, pnpm) que redirigen paquetes Python/Node/Ruby.
- Usa Fish shell por defecto, permite bash/zsh.
- Incluye ~190 herramientas documentadas en `docs/recursos/herramientas/`.

## 3. Routing por intención

| El usuario pregunta sobre... | Archivo de referencia | Docs relacionadas |
|---|---|---|
| Instalar/configurar Termux | `references/termux-setup.md` | `docs/termux/instalacion.md`, `docs/termux/configuracion.md` |
| Paquetes, repos, pkg vs apt | `references/termux-setup.md` | `docs/termux/paquetes.md` |
| i-HakLab, comandos, wrappers | `references/ihaklab.md` | `docs/recursos/herramientas-ihaklab.md` |
| Cómo instalar herramienta X | `references/tool-install.md` | `docs/recursos/herramientas/{tool}.md` |
| Adaptación glibc, binarios rotos | `references/android-limitations.md` | `docs/termux/compilacion-glibc.md` |
| proot, udocker, docker-qemu, proot-distro para agentes AI | `references/docker-alternatives.md` | `docs/android/bypass-limitaciones.md`, `docs/termux/compilacion-glibc.md` |
| Python, pip, compilación, venv | `references/python-ecosystem.md` | `docs/termux/python.md`, `docs/termux/paquetes.md#6` |
| ADB, depuración inalámbrica | `references/android-limitations.md` | `docs/android/adb.md`, `docs/android/wireless-debugging.md` |
| termux-packages (repo Ivam3) | `references/tool-install.md` | `docs/recursos/termux-packages.md` |
| Escritorio gráfico, X11, XFCE | `references/termux-setup.md` | `docs/termux/termux-x11.md` |
| Wrapper apt/npm/pnpm | `references/ihaklab.md` | `docs/recursos/herramientas-ihaklab.md#13` |
| Ecosistema de agentes AI, config compartida | `references/agent-ecosystem.md` | `docs/recursos/herramientas/{opencode,claude-code,codex,qwen-code,...}.md` |
| MCP servers en Termux (CodeGraph, TestSprite, Playwright, Smithery) | `references/agent-ecosystem.md` | `docs/recursos/herramientas/codegraph-mcp.md` |
| Adaptación glibc (deep dive), shim compat, TCMalloc | `references/agent-ecosystem.md` | `docs/termux/compilacion-glibc.md` |
| Error de compilación/instalación | `references/python-ecosystem.md` | `docs/termux/troubleshooting.md`, `docs/termux/fixer.md` |

## 4. Conceptos clave inline

### pkg vs apt
- `pkg install` = `apt update` implícito + `apt install`. Usar para instalaciones individuales.
- `apt install` = no hace `apt update` automático. Usar solo si se acaba de hacer `apt update`.
- En i-HakLab, `apt` es un wrapper que puede redirigir a pip/npm/gem.

### Wrappers i-HakLab
- `~/.local/bin/apt`: Si detecta módulo Python → `pip install`. Si detecta módulo Node → `npm install -g`. Si es nativo → delega a `$PREFIX/bin/apt`.
- `~/.local/bin/npm`: Normaliza alias (`gemini-cli` → `@google/gemini-cli`), automatiza n8n, pnpm, open-lovable.
- Post-instalación: `pkg2conf` aplica configuraciones (parches, symlinks, servicios).

### Adaptación glibc (Virtualización Ligera de Entorno)
Técnica para ejecutar binarios Linux glibc en Termux sin proot, usada por todos los agentes AI nativos.

- **Mecanismo**: binario real renombrado `.va39` + wrapper C (`*_helper.c`) que invoca `$PREFIX/glibc/lib/ld-linux-aarch64.so.1` con `--library-path`.
- **Por qué no patchelf**: Android/SELinux bloquea `seccomp` al parchear ELFs. La invocación directa del loader evita esto.
- **Node.js glibc bridge**: OpenClaw usa Node.js estándar en `~/.openclaw-android/node`. Las herramientas npm heredan glibc automáticamente.
- **Shim `glibc-compat.js`**: carga vía `NODE_OPTIONS`, redirige `process.execPath`, gestiona `LD_PRELOAD`, parchea `os.cpus`/`dns.lookup` para SELinux.
- **Limitación TCMalloc**: binarios como `agy` (Antigravity CLI) usan `tcmalloc` que requiere 48 bits de espacio virtual. Algunos kernels Android limitan esto causando `Segmentation Fault`.
- **Usado por**: opencode, claude-code, codebuff, freebuff, mimocode, antigravity-cli, openclaw, mistral-vibe.

### Docker alternatives
- `udocker`: contenedores Docker en espacio de usuario (no requiere root).
- `termux-docker-qemu`: VM Alpine vía QEMU (root real dentro de la VM).
- `proot`: fake root (reescribe syscalls, limitado).

### MCP Servers en Termux
Servidores MCP compatibles con agentes AI en Termux:

| Server | Instalación | Nota Android |
|--------|------------|-------------|
| **CodeGraph** | `npm install -g @codegraph/codegraph-mcp` | Usar `CODEGRAPH_NO_DAEMON=1` (SELinux bloquea hardlinks para PID) |
| **Context7** | `npx ctx7@latest` vía opencode.json | MCP remoto, sin issues |
| **TestSprite** | `npm install -g @testsprite/testsprite-mcp` | Plug-and-play, configurar API key |
| **Playwright (proot)** | `apt install playwright-proot` | Chromium headless vía proot Ubuntu (aarch64) |
| **Engram** | `apt install engram` | Memoria persistente para agentes (Go binary) |
| **Smithery** | `npm install -g @smithery/cli` | Requiere parche `process.platform` (android→linux). Usar endpoint unificado `https://mcp.smithery.run/<namespace>` en opencode |

## 5. Reglas de ejecución

1. **Siempre preferir `pkg install` sobre `apt install`** para instalaciones individuales.
2. Si el usuario no tiene i-HakLab, usar `pip install`/`npm install -g` directamente.
3. Si el usuario tiene i-HakLab, `apt install <tool>` funciona (wrapper).
4. Para herramientas Python con dependencias C, verificar primero si existe `python-<nombre>` en apt.
5. Para herramientas glibc, instalar desde ivam3/termux-packages.
6. No recomendar `--break-system-packages` sin antes ofrecer `venv` como alternativa.
7. Si un comando falla, sugerir ejecutar `fixer` (diagnóstico automático).

## 6. Base de conocimiento adicional

Todo el conocimiento detallado está en `/data/data/com.termux/files/.repositories/termux-oracle/docs/`:
- `termux/` — 13 archivos sobre instalación, paquetes, Python, glibc, troubleshooting, etc.
- `android/` — 5 archivos sobre ADB, Fastboot, seguridad, bypass de limitaciones.
- `recursos/` — manual i-HakLab (~970 líneas), 190+ tool docs individuales.
- `scripts/`, `laboratorios/`, `ctf/`, `glosario/`, `comunidad/`.

Usa `Glob` y `Grep` para buscar en estos archivos cuando necesites información específica que no esté en las referencias.
