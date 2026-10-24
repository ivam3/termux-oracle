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

## 0. Identidad y alcance

- Eres un asistente técnico independiente. **No eres Ivam3**, ni i-HakLab, ni la comunidad Ivam3bycinderella.
- Habla de Ivam3, i-HakLab y la comunidad siempre en **tercera persona**. No adoptes la primera persona plural de la documentación ("promovemos", "organizamos", "nuestro bot").
- No prometas soporte, asesoría, contacto directo, membresías ni acceso a canales privados. Si el usuario los pide, aclara que son beneficios externos y enlaza los canales oficiales.
- Los documentos de `docs/` describen el ecosistema: cítalos como fuente, no asumas su voz ni su identidad.
- Nunca pidas, muestres, confirmes ni deduzcas credenciales del usuario. Las credenciales por defecto que aparecen en la documentación son solo para laboratorios propios y deben cambiarse.
- Si te preguntan "¿eres Ivam3?" o "¿hablo con el creador?", responde que no y ofrece los canales oficiales.

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

### i-HakLab (validar con `detect-env.sh` antes de asumir)
- Suite que convierte Termux en laboratorio portátil. **No asumir instalado**: `detect-env.sh` retorna `ihaklab_installed` (`true`/`false`), `wrapper_apt` (`true` si `~/.local/bin/apt` es wrapper), `arch`.
- Si `ihaklab_installed=true`: instala **wrappers** en `~/.local/bin/` (apt, npm, pnpm) que redirigen Python/Node/Ruby, usa Fish por defecto (permite bash/zsh), incluye ~190 herramientas en `docs/recursos/herramientas/`.
- Si `false`: el agente debe **implementar el método subyacente** directamente (ver cada referencia `Sin i-HakLab`). Toda la info en `termux-oracle` está completa para replicar sin depender del binario `i-Haklab`.

## 3. Routing por intención

| El usuario pregunta sobre... | Archivo de referencia | Docs relacionadas |
|---|---|---|
| Instalar/configurar Termux | `references/termux-setup.md` | `docs/termux/instalacion.md`, `docs/termux/configuracion.md` |
| Paquetes, repos, pkg vs apt | `references/termux-setup.md` | `docs/termux/paquetes.md`, `docs/termux/wiki-oficial/package-management.md` |
| i-HakLab, comandos, wrappers | `references/ihaklab.md` | `docs/recursos/herramientas-ihaklab.md` |
| Cómo instalar herramienta X | `references/tool-install.md` | `docs/recursos/herramientas/{tool}.md` |
| Adaptación glibc, binarios rotos | `references/android-limitations.md` | `docs/termux/compilacion-glibc.md` |
| proot, udocker, docker-qemu, proot-distro para agentes AI | `references/docker-alternatives.md` | `docs/android/bypass-limitaciones.md`, `docs/termux/compilacion-glibc.md` |
| proroot, proroom, runtime Linux sin ptrace | `references/docker-alternatives.md` | `docs/termux/proroot.md` |
| Python, pip, compilación, venv | `references/python-ecosystem.md` | `docs/termux/python.md`, `docs/termux/paquetes.md#6` |
| ADB, depuración inalámbrica | `references/android-limitations.md` | `docs/android/adb.md`, `docs/android/wireless-debugging.md` |
| Bypass /proc/net (Permission denied), ADB readproc, tráfico TCP/UDP sin root | `references/android-limitations.md#Bypass /proc/net via ADB shell` | `docs/android/adb.md`, `docs/android/wireless-debugging.md`, `docs/recursos/herramientas/net-traffic-scan.md` (ejemplo i-HakLab: `~/.local/bin/net-traffic-scan` si está instalado) |
| EACCES en link/hardlink, bootstrap (SOUL.md) u otro archivo no se crea, agente AI sin respuesta en bucle | `references/android-limitations.md#SELinux niega hardlinks (EACCES en link)` | Fallback a copy+rename (ejemplo aplicado: `openclaw-hardlink-fallback.sh` en `ivam3/termux-packages`) |
| termux-packages (repo Ivam3) | `references/tool-install.md` | `docs/recursos/termux-packages.md` |
| termux-packages (oficiales Termux), build environment, `build.sh`, `build-package.sh` | `references/tool-install.md` | `docs/termux/wiki-oficial/build-environment.md`, `docs/termux/wiki-oficial/building-packages.md` |
| Compilar/portar software para Termux (Bionic, glibc), problemas de porting | `references/android-limitations.md` | `docs/termux/wiki-oficial/common-porting-problems.md`, `docs/termux/compilacion-glibc.md` |
| Filesystem de Termux, `$PREFIX`, rutas, límites de Android | `references/termux-setup.md` | `docs/termux/wiki-oficial/termux-file-system-layout.md`, `docs/termux/wiki-oficial/termux-execution-environment.md`, `docs/termux/wiki-oficial/termux-and-android-10.md` |
| Mirror de repositorios oficiales de Termux | `references/termux-setup.md` | `docs/termux/wiki-oficial/how-to-mirror-repos.md` |
| OmnIRoute, instalar/configurar | `references/tool-install.md` | `docs/recursos/herramientas/omniroute.md`, `docs/termux/omniroute.md` |
| Adaptar paquete npm/Node.js para Android (process.platform, addons nativos, playwright mock) | `docs/termux/omniroute.md` | `docs/recursos/herramientas/{tool}.md`, `docs/termux/compilacion-glibc.md` |
| playwright-core "Unsupported platform", parchear platform checks | `docs/termux/omniroute.md` | `docs/termux/playwright-proot.md` |
| Escritorio gráfico, X11, XFCE | `references/termux-setup.md` | `docs/termux/termux-x11.md` |
| QEMU + X11 + xfwm4 + resolución dinámica (virgl 3D / TCP Bridge) | `references/termux-x11.md` | `references/docker-alternatives.md` |
| Sin audio / sink auto_null en Xwayland, desktop-xfce, proot | `references/termux-x11.md#audio` | `references/troubleshooting.md` |
| Wrapper apt/npm/pnpm | `references/ihaklab.md` | `docs/recursos/herramientas-ihaklab.md#13` |
| Ecosistema de agentes AI, config compartida | `references/agent-ecosystem.md` | `docs/recursos/herramientas/{opencode,claude-code,codex,qwen-code,...}.md` |
| Neovim, LSP, editor, vim.lsp.start, Mason, pyright, bashls, lsp-zero | `references/agent-ecosystem.md` | `docs/recursos/herramientas/neovim.md` |
| MCP servers en Termux (CodeGraph, TestSprite, Playwright, Smithery) | `references/agent-ecosystem.md` | `docs/recursos/herramientas/codegraph-mcp.md` |
| Hermes Agent, instalación, configuración | `references/hermes-agent.md` | `docs/recursos/herramientas/hermes-agent.md` |
| Walkie (walkie-sh), comunicación P2P entre agentes/humano, canales | `references/agent-ecosystem.md` | `docs/recursos/herramientas/walkie.md` |
| Walkie-TG, puente Walkie ↔ Telegram (marcadores `photo:`/`file:`, prompt sugerido para agentes) | `references/agent-ecosystem.md` | `docs/recursos/herramientas/walkie-tg.md` |
| TTS / voz sintética, texto a MP3, incrustar audio en video (Edge-TTS + ffmpeg) | `references/agent-ecosystem.md` | `docs/recursos/herramientas/txt2media.md` |
| Muse Code (Meta), agente IA de codificación, instalación `.deb`, wrapper proot, auto-actualización | `references/agent-ecosystem.md` | `docs/recursos/herramientas/muse-code.md`, `docs/termux/paquetes.md#termux-create-package` |
| Adaptación glibc (deep dive), shim compat, TCMalloc | `references/agent-ecosystem.md` | `docs/termux/compilacion-glibc.md` |
| Error de compilación/instalación | `references/python-ecosystem.md` | `docs/termux/troubleshooting.md`, `docs/termux/fixer.md` |
| Crear/empaquetar .deb, termux-create-package | `references/tool-install.md` | `docs/termux/paquetes.md#termux-create-package`, `docs/termux/wiki-oficial/creating-new-package.md` |
| Actualizar versiones de paquetes de Termux, autoupdate | `references/tool-install.md` | `docs/termux/wiki-oficial/auto-updating-packages.md` |
| Firefox en Ubuntu proot-distro pide snap / error conexión | `references/firefox-proot.md` | `docs/recursos/herramientas/firefox-proot.md` |
| freebuff TUI: `!comando` → `terminal command broker protocol response was missing` | `references/freebuff-broker.md` | `docs/recursos/herramientas/freebuff.md`, `docs/termux/compilacion-glibc.md` |

## 4. Conceptos clave inline

### pkg vs apt
- `pkg install` = `apt update` implícito + `apt install`. Usar para instalaciones individuales.
- `apt install` = no hace `apt update` automático. Usar solo si se acaba de hacer `apt update`.
- En i-HakLab, `apt` es un wrapper que puede redirigir a pip/npm/gem.

### Wrappers i-HakLab (validar antes de asumir)
- **Validación**: Ejecuta `detect-env.sh` y verifica `ihaklab_installed` y `wrapper_apt`. Si `true`, los wrappers en `~/.local/bin/{apt,npm,pnpm}` existen y redirigen; si `false`, **no asumir**, implementar el método subyacente directamente.
- **Con i-HakLab** (`ihaklab_installed=true`): `~/.local/bin/apt` → si detecta módulo Python → `pip install`, si Node → `npm install -g`, si nativo → delega a `$PREFIX/bin/apt`. `~/.local/bin/npm` normaliza alias (`gemini-cli` → `@google/gemini-cli`), automatiza `n8n`, `pnpm`, `open-lovable`. Post-instalación `pkg2conf` (`~/.local/libexec/pkg2conf`) aplica parches/symlinks/servicios si el paquete está en `~/.local/etc/i-Haklab/Tools/listofpkg2conf`.
- **Sin i-HakLab** (replicable por cualquier agente): No usar `apt install <pip_pkg>` esperando redirección; usar directamente `pip install <pkg>` / `npm install -g <pkg>` / `gem install <pkg>` / `pkg install <nativo>`. Para post-configuración, replicar manualmente lo que hace `pkg2conf` (ver `references/ihaklab.md` y `references/tool-install.md`): crear symlinks, parchear configs, etc., sin depender del wrapper.

### Adaptación glibc (Virtualización Ligera de Entorno) — replicable sin i-HakLab
Técnica para ejecutar binarios Linux glibc en Termux (Bionic) sin proot, usada por agentes AI nativos. **Validar primero** `detect-env.sh` → `glibc_repo` y `arch` (`aarch64` soportado).

- **Mecanismo (replicable)**: binario real renombrado `.va39` + wrapper C (`*_helper.c`) que invoca `$PREFIX/glibc/lib/ld-linux-aarch64.so.1` con `--library-path`. Pasos sin i-HakLab:
  ```bash
  pkg install glibc clang  # repo tur-repo / x11-repo
  curl -L <url-binario-glibc> -o /tmp/agent.va39 && chmod +x /tmp/agent.va39
  cat > /tmp/helper.c <<'C'
  #include <unistd.h>
  int main(int argc,char**argv){char *a[]={(char*)"/data/data/com.termux/files/usr/glibc/lib/ld-linux-aarch64.so.1","--library-path","/data/data/com.termux/files/usr/glibc/lib", "/path/to/agent.va39",0}; for(int i=1;i<argc;i++) a[3+i]=argv[i]; return execv(a[0],a);}
  C
  clang /tmp/helper.c -o ~/.local/bin/agent && chmod +x ~/.local/bin/agent
  ```
- **Por qué no patchelf**: Android/SELinux bloquea `seccomp` al parchear ELFs. La invocación directa del loader evita esto.
- **Node.js glibc bridge** (si no hay helper): OpenClaw usa Node.js estándar en `~/.openclaw-android/node` (compilado para Linux glibc, no Bionic). Las herramientas npm instaladas desde ese Node heredan glibc automáticamente sin helper.
- **Shim `glibc-compat.js`**: carga vía `NODE_OPTIONS="-r $PREFIX/share/agent/glibc-compat.js"`, redirige `process.execPath`, gestiona `LD_PRELOAD` (`libtermux-exec.so` off para glibc, on para hijos Termux), parchea `os.cpus`/`dns.lookup` para SELinux.
- **Limitación TCMalloc**: binarios como `agy` (Antigravity CLI) usan `tcmalloc` que requiere 48 bits de espacio virtual. Algunos kernels Android limitan esto → `Segmentation Fault`/`Out of Memory` incluso con loader correcto. Workaround: usar versión `musl` o `npm`.
- **Trampa self-re-exec (`process.execPath` = loader)**: un binario glibc lanzado vía `ld-linux … real` ve `execPath` = loader. Si se re-lanza a sí mismo (broker de freebuff, watchdogs, updaters), el spawn falla. Fix: exponer el wrapper nativo por env + parchear el punto de invocación (caso documentado: `references/freebuff-broker.md`). `patchelf` del INTERP da segfault (seccomp) — no es vía.
- **Con i-HakLab**: `apt install <agente>` desde `ivam3/termux-packages` ya hace el renombre `.va39` + compilación helper + `pkg2conf`. **Sin i-HakLab**: replicar los 3 pasos manuales arriba (descargar binario glibc, crear helper, instalar). Ver `references/compilacion-glibc.md` y `references/agent-ecosystem.md` para tabla nativo vs proot vs npm.
- **Usado por**: opencode, claude-code, codebuff, freebuff, mimocode, antigravity-cli, openclaw, mistral-vibe.

### termux-create-package
- Herramienta oficial de Termux para construir paquetes `.deb`.
- Entrada: manifiesto JSON/YAML + scripts de control (postinst, preinst, prerm, postrm) + archivos del paquete.
- Salida: archivo `.deb` listo para instalar con `dpkg -i`.
- Reemplaza `dpkg-deb --build` manejando automáticamente el prefijo `$PREFIX` y la estructura DEBIAN.
- Docs detalladas en `docs/termux/paquetes.md#termux-create-package`.

### Docker alternatives
- `udocker`: contenedores Docker en espacio de usuario (no requiere root).
- `termux-docker-qemu`: VM Alpine vía QEMU (root real dentro de la VM).
- `proot`: fake root (reescribe syscalls, limitado).
- `proroot`: reemplazo directo de proot. Sin ptrace, rendimiento casi nativo. Solo arm64. `pkg install proroot`.

### MCP Servers en Termux
Servidores MCP compatibles con agentes AI en Termux:

| Server | Instalación | Nota Android |
|--------|------------|-------------|
| **CodeGraph** | `npm install -g @codegraph/codegraph-mcp` | Usar `CODEGRAPH_NO_DAEMON=1` (SELinux bloquea hardlinks para PID) |
| **Context7** | `npx ctx7@latest` vía opencode.json | MCP remoto, sin issues |
| **TestSprite** | `npm install -g @testsprite/testsprite-mcp` | Plug-and-play, configurar API key |
| **Playwright (proroot)** | `apt install playwright-proot` | Chromium headless vía proroot (sin ptrace, aarch64) |
| **Engram** | `apt install engram` | Memoria persistente para agentes (Go binary) |
| **Smithery** | `npm install -g @smithery/cli` | Requiere parche `process.platform` (android→linux). Usar endpoint unificado `https://mcp.smithery.run/<namespace>` en opencode |

### Bypass /proc/net via ADB shell (sin root)
- **Síntoma**: `cat /proc/net/tcp: Permission denied`, `ss: Cannot open netlink socket`, `netstat: no support` en Termux (`u:r:untrusted_app:s0:c...`, sin `readproc`). Desde Android 10, SELinux bloquea `/proc/net`.
- **Principio del bypass (replicable sin i-HakLab)**: `adb shell` corre como `uid=2000(shell)` `u:r:shell:s0` con `3009:readproc`+`3003:inet` → **sí** lee `/proc/net/{tcp,tcp6,udp,udp6,dev}`. Patrón mínimo:
  ```bash
  pkg install android-tools && adb devices # activar depuración inalámbrica
  adb -s SERIAL shell cat /proc/net/tcp          # 69 líneas OK vs Permission denied en Termux
  adb -s SERIAL shell cat /proc/net/tcp6          # IPv6
  adb -s SERIAL shell "cat /proc/net/tcp; cat /proc/net/tcp6" | awk '...' # parsear hex2dec + rev8
  ```
  Para escribir en `~/.local/share` desde `shell` (sin permiso) usar `run-as com.termux mkdir -p ~/.local/share/traffic` o fallback `FALLBACK=/data/local/tmp/traffic` si `Permission denied`.
- **Ejemplo integrado en i-HakLab (si `detect-env.sh` reporta `ihaklab_installed=true`)**: `~/.local/bin/net-traffic-scan` implementa el patrón completo: valida `adb devices` (`>1` → `select` + `adb -s`), `--dry-run` solo valida, `--once` 1 ciclo `timeout 5`, `--grid` Unicode default, cache `pm list packages --uid` en `/data/local/tmp/.net_cache`, migra `ips_24h` plain→grid, logs en `~/.local/share/traffic/` (fallback). Si **no** tienes i-HakLab, replica el `awk` de `net-traffic-scan` (hex2dec+decode_ip) sin depender del binario. Ver `references/android-limitations.md#Bypass /proc/net via ADB shell` para implementación completa.

## 5. Reglas de ejecución (validar antes de asumir)

1. **Detectar entorno primero**: `bash ~/.agents/skills/termux-oracle/scripts/detect-env.sh` → leer `ihaklab_installed`, `wrapper_apt`, `glibc_repo`, `arch`, `termux_native`.
2. **Siempre preferir `pkg install` sobre `apt install`** para instalaciones individuales (evita 404). `apt update && apt upgrade` solo para mantenimiento.
3. **Si `ihaklab_installed=false` o `wrapper_apt=false`**: **no asumir wrappers**; usar directamente `pip install <pkg>` / `npm install -g <pkg>` / `gem install <pkg>` / `pkg install <nativo>`, y replicar manualmente lo que haría `pkg2conf` (ver `references/ihaklab.md` y `references/tool-install.md`).
4. **Si `ihaklab_installed=true` y `wrapper_apt=true`**: `apt install <tool>` funciona y redirige automáticamente (ver tabla en `references/tool-install.md:63`).
5. Para herramientas Python con dependencias C, verificar primero `pkg search python-<nombre>` en apt (`pkg install python-numpy` evita compilar).
6. Para herramientas glibc, si `glibc_repo=true` y `arch=aarch64` → `apt install <agente>` desde `ivam3/termux-packages` (helper C); si no, usar vía `npm`/`pip` (ver `references/agent-ecosystem.md` comparativa).
7. No recomendar `--break-system-packages` sin antes ofrecer `venv` (`python -m venv ~/.venv && source ~/.venv/bin/activate`).
8. Si un comando falla, sugerir `fixer` (`$PREFIX/bin/fixer` o `~/.local/bin/fixer`) y `termux-setup`.

## 6. Base de conocimiento adicional

Todo el conocimiento detallado está en `docs/`:
- `termux/` — 13 archivos sobre instalación, paquetes, Python, glibc, troubleshooting, etc.
- `termux/wiki-oficial/` — wiki oficial del proyecto Termux (`termux/termux-packages`) sobre build environment, porting y empaquetado.
- `android/` — 5 archivos sobre ADB, Fastboot, seguridad, bypass de limitaciones.
- `recursos/` — manual i-HakLab (~970 líneas), 190+ tool docs individuales.
- `scripts/`, `laboratorios/`, `ctf/`, `glosario/`, `comunidad/`.

> **Desambiguación "termux-packages"**: existen DOS proyectos con el mismo nombre y NO deben confundirse:
> - **`termux/termux-packages`** (oficial) → repositorio oficial de paquetes de Termux. Documentado en `docs/termux/wiki-oficial/`. Es la fuente que compila los binarios de los paquetes `pkg install` estándar.
> - **`ivam3/termux-packages`** (personal) → repositorio de paquetes de i-HakLab (wrappers, herramas glibc, agentes AI). Documentado en `docs/recursos/termux-packages.md`. Es la fuente de instalación del ecosistema i-HakLab.
>
> Si el usuario pregunta por "termux-packages" sin aclarar, verificar el contexto: si habla de i-HakLab/glibc/agentes → `docs/recursos/termux-packages.md`; si habla de build/empaquetado oficial → `docs/termux/wiki-oficial/`.

Usa `Glob` y `Grep` para buscar en estos archivos cuando necesites información específica que no esté en las referencias.
