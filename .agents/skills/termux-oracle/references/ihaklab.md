# i-HakLab Reference — validar antes de asumir

> **Validación**: Ejecuta `bash ~/.agents/skills/termux-oracle/scripts/detect-env.sh | jq .ihaklab_installed` . Si `false`, **no asumir** que `i-Haklab`, `~/.local/bin/apt`, `~/.local/bin/net-traffic-scan` o `~/.local/etc/i-Haklab/*` existen. Toda la info aquí es replicable sin i-Haklab (ver `Sin i-HakLab` en cada sección). Si `true`, puedes usar los wrappers y comandos tal cual.

i-HakLab v3.13 es un laboratorio de hacking para Termux/Android creado por @Ivam3byCinderella. Si `detect-env.sh` reporta `ihaklab_installed=false`, replica el método subyacente descrito en cada sección sin depender del binario.

## Comando principal
```bash
i-Haklab <opción> [argumentos]
```

## Setting Options
| Comando | Función |
|---------|---------|
| `about <tool>` | Info sobre herramienta |
| `aptup` | Actualiza Termux manualmente |
| `help` | Muestra ayuda |
| `passwd set\|new` | Configura login |
| `pd <distro>` | Ejecuta distro Linux en proot |
| `setapikey` | Configura API keys |
| `setshell` | Cambia shell (bash/zsh/fish) |
| `setuser` | Configura nombre de usuario |
| `show alltools\|instatools\|books\|tutorials` | Lista herramientas/libros/tutoriales |
| `speedtest` | Prueba de velocidad |
| `weechat` | Conecta IRC |
| `Xwayland` | Escritorio XFCE4 sobre Wayland |

## Automatization Options
| Comando | Función |
|---------|---------|
| `androforensic secretCodes\|airscope\|dumpsys\|extract` | Forense Android vía ADB |
| `backup create\|restore` | Backup de Termux |
| `bruteforce ftp\|mail\|ssh\|telnet` | Fuerza bruta |
| `chatAI` | Asistente IA vía OpenAI |
| `msf dirscan\|embed\|payapk\|payexe\|paypdf\|shodan` | Automatizaciones Metasploit |
| `tunnel -p <port> -s <subdomain>` | TCP port forwarding |
| `qemufy <file.zip\|rm>` | Máquinas virtuales QEMU sin root |
| `servers4test` | Laboratorios vulnerables (bWAPP/DVWA/mutillidae) |
| `4share localtunnel\|localhost.run\|cloudflared` | Servidor para compartir archivos |
| `phonescan <number>` | Escaneo telefónico |

## AI Agents & Tools
i-Haklab integra agentes de IA y herramientas asociadas. Ver referencia completa en `references/agent-ecosystem.md`.

**Agentes disponibles** (vía apt/npm):
`opencode`, `claude-code`, `openclaw`, `qwen-code`, `mistral-vibe`, `antigravity-cli`, `copilot-cli`, `codebuff`, `freebuff`, `mimocode`, `codex-cli`, `minimax-cli`, `open-lovable`, `codecompanion`, `smithery`

**Herramientas asociadas**:
`engram`, `omniroute`, `playwright-proot`, `context7`, `openspec`, `termux-oracle-skill`, `n8n`, `smithery`

### Playwright en proot
```bash
apt install playwright-proot
```
Instala Chromium headless vía proot Ubuntu (aarch64). Usar con:
```bash
playwright-proot <comando>
```

### TestSprite MCP
```bash
npm install -g @testsprite/testsprite-mcp@latest
```
Configurar API key en `opencode.json`:
```json
{
  "mcp": {
    "TestSprite": {
      "type": "local",
      "command": ["testsprite-mcp-plugin"],
      "environment": {
        "API_KEY": "sk-user-..."
      },
      "timeout": 60000,
      "enabled": true
    }
  }
}
```

### Comando `ai` (wrapper hybrid-cli-ai)
`ai` es un wrapper de `hybrid-cli-ai` (instalado editable en `~/.local/share/hybrid-cli-ai`) que captura por voz y decide entre ejecutar o sugerir.

**Comportamiento:**
- `ai "<consulta>"` → captura por voz (`termux-dialog speech`) y ejecuta la respuesta (default `--run`).
- `ai --no-run "<consulta>"` o `ai -v --no-run` → voz + solo sugerir (no ejecuta).
- `ai --model <modelo>` → cambia de modelo (default `qwen2.5-coder:1.5b` local vía Ollama).
- `ai disable` → elimina el wrapper (`cleanup ai`).
- Auto-inicia Ollama (`ollama serve`) con health-check sobre `http://127.0.0.1:11434/api/tags`.
- Mapea `APIKEY_groq` → `GROQ_API_KEY` para usar el endpoint de Groq si no hay modelo local.

**Adaptación a Termux** (el wrapper re-aplica un parche idempotente tras reinstalar):
- `utils.py get_os_info()` devuelve `"termux"` si existe `$PREFIX` o `/data/data/com.termux`.
- `ai_engine.py OS_INSTRUCTIONS["termux"]`: sin `sudo`, usar `$PREFIX`/`$HOME`, instalar con `pkg install`, e incluye la suite i-HakLab en el contexto.

**Conocimiento de i-HakLab:** el wrapper antepone un cheat-sheet (`IHK_CTX`) al prompt SOLO si la consulta menciona `i-haklab|ihaklab|setapikey|helpper|alltools|wrapper|documentacion|apikey|clave de|groq`. Mantiene limpias las consultas normales y responde con i-HakLab cuando corresponde.

**Gotchas:**
- typer usa UN solo argumento: el contexto a anteponer + la consulta deben ir unidos en un solo string.
- `--no-run` se extrae ANTES de la captura de voz y se limpia al unir (`${joined//--no-run/}`), para que `ai -v --no-run` funcione.
- Modelos 1.5b fallan en tareas de usuarios del sistema (ej. `cat /etc/passwd`); usar un modelo mayor cuando se requiera.
- Documentación completa en `~/.local/etc/i-Haklab/Tools/Readme/ai.md`.

## Direct Commands (sin prefijo i-Haklab) — validar `detect-env.sh` primero
> Si `ihaklab_installed=false`, estos comandos **no existen** como `~/.local/bin/*`. No asumir; replicar el método subyacente (ver `Sin i-HakLab` en cada caso) o instalar i-HakLab primero.

`apt`, `adminfiles`, `cmd`, `fixer`, `gitbrowsering`, `lock`, `mypip`, `net-traffic-scan`, `nls`, `proxy`, `rmcache`, `serverapache`, `serverphp`, `sudo`, `traductor`, `postgresql`

- `nls` → listar archivos en cajas/grids (alternativa a `ls` para texto en recuadros). Binario Go en `~/go/bin/nls`, declarado en `functions`.
- `net-traffic-scan` → monitor de tráfico TCP/UDP vía ADB `readproc` bypass (ver `references/android-limitations.md#Bypass /proc/net via ADB shell`). Si no hay i-HakLab, replicar con `adb shell cat /proc/net/{tcp,udp}` + `awk hex2dec` (ver `~/.local/bin/net-traffic-scan` como referencia).

## Credenciales por defecto

> **Inseguras de fábrica.** Son valores públicos y compartidos: cámbialos en el primer inicio y no los uses en producción ni en equipos accesibles desde red.

- Login i-HakLab: `Ivam3byCinderella`
- 4share: `Admin:password`
- servers4test bWAPP: `bee:bug`
- servers4test DVWA DB: `root:root`

## Comandos útiles para el agente
```bash
# Ver todas las herramientas disponibles
i-Haklab show alltools
# Información de una herramienta
i-Haklab about <tool>
# Ver tutoriales (incluye "termux tips cap 1.1" y "termux tips cap 14")
i-Haklab show tutorials
```

## Archivos clave de i-HakLab
| Ruta | Contenido |
|------|-----------|
| `~/.local/bin/i-Haklab` | Comando principal |
| `~/.local/bin/ai` | Wrapper de IA por voz (hybrid-cli-ai) |
| `~/.local/bin/apt` | Wrapper de apt |
| `~/.local/bin/npm` | Wrapper de npm |
| `~/.local/etc/i-Haklab/functions` | Funciones de shell internas |
| `~/.local/etc/i-Haklab/variables` | Variables internas (no editar) |
| `~/.local/etc/i-Haklab/envvariables` | Variables de entorno |
| `~/.local/etc/i-Haklab/Tools/listoftools` | Lista maestra de herramientas |
| `~/.local/etc/i-Haklab/Tools/listofpkg2conf` | Paquetes con post-configuración |
| `~/.local/etc/i-Haklab/Tools/Readme/` | Docs individuales de cada herramienta |
| `~/.local/libexec/pkg2conf` | Orquestador post-instalación |
| `~/.local/libexec/i-Haklab/setshell` | Cambio de shell |
| `$PREFIX/usr/bin/fixer` | Diagnóstico y reparación |
| `$PREFIX/share/man/man1/i-Haklab.1` | Man page |

## Wrappers (comportamiento) — validar `wrapper_apt` antes de asumir
> **Validar**: `detect-env.sh | jq .wrapper_apt` . Si `false`, no hay wrappers; usar comandos subyacentes directamente.

- **Con i-HakLab** (`wrapper_apt=true`): `apt install <herramienta>` → detecta si es Python/Node/Ruby y redirige a `pip`/`npm`/`gem`; si es nativo, delega a `$PREFIX/bin/apt`. Post-instalación `pkg2conf` si está en `listofpkg2conf`. `npm install <paquete>` normaliza alias (ver `references/agent-ecosystem.md`), ejecuta `pkg2conf`. `smithery` → `pkg2conf` parchea `process.platform`; `sleepwalker` → `npm install -g @sleepwalkerai/cli`; `n8n` → instala `nodejs-lts`, `libsqlite`, `sqlite`, `pm2`, `gyp`; `pnpm` → `corepack enable && pnpm setup`.
- **Sin i-HakLab** (replicable): `pkg install <nativo>` / `pip install <pkg>` / `npm install -g <pkg>` / `gem install <pkg>` directamente, sin esperar redirección. Para post-config, replicar manualmente `pkg2conf` (symlinks, parches en `~/.config`, `~/.local/share`) ver `~/.local/libexec/pkg2conf` como referencia.
