# AI Agent Ecosystem in Termux

Guía de compatibilidad, configuración compartida y adaptación glibc para agentes de IA en Termux.

## Global Agents Config (AGENTS.md compartido)

i-Haklab permite centralizar las instrucciones de todos los agentes en un único `AGENTS.md` ubicado en `~/.config/shared/AGENTS.md`.

### OpenCode / MimoCode
```json
// ~/.config/opencode/opencode.json
{
  "instructions": ["~/.config/shared/AGENTS.md"]
}
```
Igual en `~/.config/mimocode/config.json`.

### Antigravity CLI (agy)
```json
// ~/.gemini/settings.json
{
  "context": {
    "fileName": ["GEMINI.md", "AGENTS.md"]
  }
}
```
```bash
ln -sf ~/.config/shared/AGENTS.md ~/.gemini/AGENTS.md
```

### Qwen Code
```json
// ~/.qwen/settings.json
{
  "context": {
    "fileName": ["QWEN.md", "AGENTS.md"]
  }
}
```
```bash
ln -sf ~/.config/shared/AGENTS.md ~/.qwen/AGENTS.md
```

### Codex CLI
```toml
# ~/.codex/config.toml
model_instructions_file = "/data/data/com.termux/files/home/.config/shared/AGENTS.md"
```
```bash
ln -sf ~/.config/shared/AGENTS.md ~/.codex/AGENTS.md
```

### OpenClaw
```bash
mv ~/.openclaw/workspace/AGENTS.md ~/.openclaw/workspace/AGENTS.md.local
ln -sf ~/.config/shared/AGENTS.md ~/.openclaw/workspace/AGENTS.md
```

### Manicode / Codebuff
No aplican — solo leen `AGENTS.md` por proyecto.

## Estrategia de Adaptación glibc (Deep Dive)

i-Haklab implementa una técnica de **Virtualización Ligera de Entorno** para ejecutar binarios Linux glibc en Termux sin `proot`.

### Componentes Clave

| Componente | Ruta | Función |
|------------|------|---------|
| Prefijo Glibc | `$PREFIX/glibc/` | Librerías GNU C aisladas |
| Cargador Dinámico | `$PREFIX/glibc/lib/ld-linux-aarch64.so.1` | Punto de entrada para binarios glibc |
| Wrapper C | `$PREFIX/share/<agent>/<agent>_helper.c` | Bootstrapper compilado con clang |
| Binario Real | `~/.local/share/<agent>/<agent>.va39` | Binario original renombrado |

### Ejecución vía Loader (por qué no patchelf)

En lugar de parchear el ELF (que Android/SELinux bloquea con `seccomp`), se invoca directamente el cargador:

```bash
exec "$PREFIX/glibc/lib/ld-linux-aarch64.so.1" \
  --library-path "$PREFIX/glibc/lib" \
  "/ruta/al/binario.real" "$@"
```

### Node.js Glibc Bridge

OpenClaw instala una versión de **Node.js compilada para Linux estándar** en `~/.openclaw-android/node`. Las herramientas npm instaladas desde este Node.js heredan automáticamente el entorno glibc.

### glibc-compat.js Shim

Se carga automáticamente via `NODE_OPTIONS="-r ...glibc-compat.js"`. Sus funciones:

1. **`process.execPath`**: redirige al wrapper de Node para que los subprocesos hijos no fallen
2. **Gestión de `LD_PRELOAD`**: desactiva `libtermux-exec.so` para procesos glibc, lo restaura para hijos Termux
3. **Parches hot**: sobrescribe `os.cpus`, `os.networkInterfaces`, `dns.lookup` para mitigar SELinux

### Limitaciones Conocidas

**TCMalloc y espacio de direcciones**: binarios como `agy` (Antigravity CLI) usan `tcmalloc`, que espera 48 bits de espacio virtual. Algunos kernels Android limitan este espacio, causando `Out of Memory` o `Segmentation Fault` incluso con el loader glibc correcto.

## Comparativa: Nativo glibc vs proot-distro vs npm

| Aspecto | Nativo glibc (helper.c) ✅ | proot-distro (legacy) | npm/pnpm |
|---------|---------------------------|----------------------|----------|
| **Rendimiento** | Máximo (ejecución directa) | Medio (overhead proot) | Medio-alto |
| **Arquitectura** | Solo aarch64 | Todas (arm, i686, etc.) | Todas |
| **Señales/procesos** | Completo | Limitado (proot no pasa todas las syscalls) | Completo |
| **Integración FS** | Directa con Termux | Aislada en `/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/` | Directa |
| **Dependencias** | glibc, clang, python | proot-distro + distro Alpine/Ubuntu | nodejs |
| **Latencia arranque** | ~0ms | ~1-3s (inicio proot) | ~100ms |
| **Helper C** | Sí, compila `*_helper.c` | No | No |
| **Caso de uso** | Producción, uso diario | Testing, compatibilidad cruzada | Usuarios sin ivam3 repo |

### Método legacy: proot-distro para agentes AI

Antes de la adaptación glibc nativa, opencode y claude-code se ejecutaban dentro de **Alpine Linux** via proot-distro:

```bash
# Instalar distro
proot-distro install alpine

# Ejecutar agente dentro de proot
proot-distro login alpine -- opencode
proot-distro login alpine -- claude
```

**Archivos relevantes** (de los paquetes antiguos):
- `$PREFIX/share/opencode/opencode` — script que hacía `proot-distro login alpine -- opencode "$@"`
- `$PREFIX/share/claude-code/claude-code` — equivalente para claude-code

Este método fue reemplazado por el nativo glibc a partir de julio 2026. Los paquetes `.deb` actuales ya no usan proot.

## Agentes con soporte glibc nativo en termux-packages

| Agente | Helper C | Binario real | CLI |
|--------|----------|-------------|-----|
| opencode | `opencode_helper.c` | `opencode.real` | `opencode` |
| claude-code | `claudecode_helper.c` | `claude-code.va39` | `claude` |
| codebuff | `codebuff_helper.c` | `codebuff.real` | `codebuff` |
| freebuff | `freebuff_helper.c` | `freebuff.real` | `freebuff` |
| mimocode | `mimocode_helper.c` | `mimocode.real` | `mimocode` |
| antigravity-cli | `agy_helper.c` | `agy.real` | `agy` |
| openclaw | — (autónomo) | `~/.openclaw-android/node/bin/node` | `openclaw` |
| mistral-vibe | — (Python/uv) | `~/.local/share/uv/tools/mistral-vibe/` | `vibe` |

## Tabla de alias npm (wrappers i-Haklab)

| Comando | Se traduce a | Tipo |
|---------|-------------|------|
| `qwen-code` | `@qwen-code/qwen-code` | npm |
| `copilot-cli` | `@github/copilot` | npm |
| `gemini-cli` | `@google/gemini-cli` | npm |
| `claude-code` | `@anthropic-ai/claude-code` | npm |
| `codex` | `@mmmbuto/codex-cli-termux@latest` | npm |
| `minimax-cli` | `mmx-cli` | npm |
| `openspec` | `@fission-ai/openspec` | npm |
| `context7` | `ctx7` | npx |
| `smithery` | `@smithery/cli` | npm (pkg2conf parchea `process.platform`) |
| `n8n` | `n8n` (con pre-requisitos pm2/gyp) | npm |
| `open-lovable` | Clona `firecrawl/open-lovable` + npm install | git+npm |

## Smithery CLI

[Smithery](https://smithery.ai) es un marketplace y proxy de MCP servers. Permite descubrir, conectar y gestionar MCP servers desde un solo punto.

### Instalación

```bash
npm install -g @smithery/cli
smithery auth login     # Autenticación vía navegador
```

### Parche para Android (Termux)

`process.platform` en Android devuelve `"android"`, pero el bundle ofuscado de Smithery solo contempla `win32`, `darwin` y `linux`. Sin parche, lanza:

```
TypeError: Cannot destructure property 'baseDir' of 'Ahe[Ohe]' as it is undefined.
```

**Solución en i-HakLab** (vía `pkg2conf`): el wrapper npm normaliza `@smithery/cli` y el post-instalador aplica:

```bash
sed -i 's/Ohe=process.platform,{baseDir:/Ohe=process.platform==="android"?"linux":process.platform,{baseDir:/' \
  "$PREFIX/lib/node_modules/@smithery/cli/dist/index.js"
termux-fix-shebang "$PREFIX/lib/node_modules/@smithery/cli/dist/index.js"
```

### Unified Endpoint (Namespace Proxy)

Smithery expone un endpoint unificado por namespace que enruta a **todos los MCP servers conectados** en la cuenta:

```
https://mcp.smithery.run/<namespace>
```

Configuración en `opencode.json`:

```json
{
  "smithery": {
    "type": "remote",
    "url": "https://mcp.smithery.run/ivam3-bh",
    "enabled": true,
    "headers": {
      "X-API-Key": "smry_..."
    }
  }
}
```

Esto reemplaza la necesidad de configurar cada MCP server individualmente con `--client <agent>`.

## MCP Servers compatibles con Termux

| Server | Instalación | Config opencode.json |
|--------|------------|---------------------|
| **CodeGraph** | `npm install -g @codegraph/codegraph-mcp` | `command: ["codegraph", "serve", "--mcp"], env: { CODEGRAPH_NO_DAEMON: "1" }` |
| **Context7** | `npx ctx7@latest` | MCP remoto: `url: "https://mcp.context7.com/mcp"` |
| **TestSprite** | `npm install -g @testsprite/testsprite-mcp` | `command: ["testsprite-mcp-plugin"]` |
| **Playwright (proot)** | `apt install playwright-proot` | `command: ["playwright-proot"]` |
| **Smithery (unified)** | `npm install -g @smithery/cli` | MCP remoto: `url: "https://mcp.smithery.run/<namespace>"`, requiere `X-API-Key` header + OAuth |
