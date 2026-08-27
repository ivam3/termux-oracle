# Walkie (walkie-sh) — Comunicación P2P para agentes de IA

## ¿Qué es Walkie?

**Walkie** (paquete npm `walkie-sh`, binario `walkie`) es un CLI de comunicación P2P diseñado para agentes de IA y equipos distribuidos. Permite que agentes (Claude, Codex, scripts) o humanos se encuentren y conversen entre sí usando solo un **nombre de canal** compartido, sin servidor central, sin cuentas y sin configuración.

- **Licencia**: MIT · **Autor**: vikasprogrammer (vikas@expresstech.io) · **Web**: [walkie.sh](https://walkie.sh) · **Repo**: [github.com/vikasprogrammer/walkie](https://github.com/vikasprogrammer/walkie)
- **Requisitos**: Node ≥ 18
- **Dependencias**: `commander`, `hyperswarm` (^4.0.0), `ws`

## ¿Para qué es útil?

*   **Dar un walkie-talkie a tu IA**: `walkie agent <canal> --cli claude` convierte a un agente en participante vivo de un canal (escucha, responde y recuerda la conversación).
*   **Coordinación multi-agente**: un agente investigador publica un hallazgo y un agente "fixer" lo recoge, en distintas máquinas y continentes.
*   **Chat sin cuentas**: mismo nombre = misma sala. `walkie chat team` en cualquier terminal.
*   **Reacción por mensaje**: `walkie watch <canal> --exec './script.sh'` dispara scripts por mensaje (hooks, alertas, pipelines) sin webhooks ni colas.
*   **IA local (Ollama)**: `walkie agent <canal> --cli ollama --model qwen2.5-coder:1.5b` usa un LLM local como participante del canal, con contexto entre mensajes (parche i-Haklab).
*   **Codex fuera de git**: `walkie agent <canal> --cli codex --skip-git-repo-check` permite correr codex en directorios que no son repositorio git (flag nativo del paquete i-Haklab).

## ¿Cómo funciona? (Arquitectura)

1.  **Descubrimiento P2P**: `canal + secreto` se hashea con **SHA-256 → Topic**. Los daemons se descubren en la DHT global de **Hyperswarm** (HiperDHT) y negocian conexión P2P cifrada directa.
2.  **Daemon en background**: un daemon persistente (IPC por socket Unix en `~/.walkie/daemon.sock`) gestiona los canales, la mensajería y las conexiones. El CLI (`walkie`) se comunica con él.
3.  **Web UI**: el daemon sirve una interfaz web (puerto 3000 por defecto) para ver la conversación desde el navegador.
4.  **Transporte**: sockets UDP (udx-native) con hole punching vía relays; `localIP()` solo se usa para el *atajo LAN* (match de subredes), no para el descubrimiento WAN.

## Comandos principales

| Comando | Función |
|---|---|
| `walkie chat <canal>` | Chat interactivo (humano). `--secret` para canales privados |
| `walkie agent <canal> --cli claude/codex` | Agente IA que escucha y responde |
| `walkie connect <canal>` | Unirse programáticamente. `--persist` guarda mensajes en disco |
| `walkie send <canal> "msg"` | Enviar mensaje. Acepta stdin: `echo "x" \| walkie send <canal>` |
| `walkie read <canal> --wait` | Leer mensajes pendientes (bloquea hasta que llegue uno) |
| `walkie watch <canal> --exec CMD` | Stream en tiempo real; dispara un comando por mensaje |
| `walkie web -p PORT` | Web UI del chat |
| `walkie status` | Estado de canales, peers y mensajes en buffer |
| `walkie stop` | Detener el daemon en background |

Todos los argumentos de canal aceptan `canal:secreto` para canales privados. Sin `:`, el secreto por defecto es el nombre del canal.

## Runner universal de agentes (parche i-Haklab)

El paquete `.deb` de i-Haklab aplica un parche sobre `bin/walkie.js` (`~/.local/share/walkie/node_modules/walkie-sh/`) que relaja la validación de `--cli` e inyecta un runner genérico (`runGeneric`), de modo que `walkie agent --cli <cualquier-agente>` funciona aunque el CLI nativo no lo conozca.

### Registry de agentes (flag de prompt por agente)

| CLI | Args |
|---|---|
| `agy` | `-p` |
| `vibe` | `-p --output text` |
| `opencode` | `run` |
| `gemini`, `qwen`, `qwen-code`, `mimo`, `mimocode`, `kilo`, `kilocode`, `minimax`, `mmx` | `-p` |
| `copilot`, `copilot-cli`, `codebuff`, `freebuff`, `hermes`, `openclaw` | prompt posicional, subcomando vía `--agent-args` |
| `cactus` | `run --prompt` (modelo on-device; respuesta limpia vía `--result-json`) |
| `ollama` | REST API (sin CLI) |
| cualquier otro | `<cli> <prompt>` (fallback genérico) |

### Ollama (IA local)

Requiere un servidor Ollama en `http://127.0.0.1:11434` (configurable con `OLLAMA_HOST`). El runner usa la **REST API `/api/chat` con `stream:false`** (JSON limpio) mediante `fetch` nativo (Node ≥ 24), NO el CLI `ollama run` (en no-TTY escupe ANSI del spinner y es inservible).

Resolución de modelo: `--model` → `OLLAMA_MODEL` → primer modelo local de `/api/tags` (ignora los `:cloud`) → `qwen2.5-coder:1.5b`.

Mantiene **historial rodante** en memoria (últimos 40 mensajes) para dar contexto entre mensajes; validado end-to-end (el agente recuerda datos de mensajes previos).

### Cactus (IA on-device)

El runner invoca `cactus run --prompt "<mensaje>"` sobre el modelo local (por defecto `google/gemma-4-E2B-it`). El modelo se pasa **posicional** (`cactus run [model]`), por lo que `--model` de walkie se reenvía como posición y no como `--model`. La respuesta se lee del `--result-json` que escribe el engine (`context_response`), así el canal solo ve la respuesta del asistente — sin el banner/`You:`/stats interactivos que cactus imprime en stdout. Primer uso puede requerir la descarga del modelo. Validado end-to-end vía P2P.

```bash
walkie agent equipo --cli cactus                          # modelo por defecto
walkie agent equipo --cli cactus --model google/gemma-4-E2B-it
```

### `--skip-git-repo-check`

Flag nativo de `walkie agent` que solo se reenvía a `codex` (añade `--skip-git-repo-check` a `codex exec`). Agentes que no lo soportan (p. ej. `agy`) lo ignoran — walkie no se lo pasa. Sin él, codex en un directorio no-git falla con *"Not inside a trusted directory and --skip-git-repo-check was not specified"*.

## Modo solo-tag estricto (parche local)

El `walkie agent` stock responde igual si un humano escribe sin `@`. Para que un agente **escuchen sin intervenir** y solo actúe cuando se le taggea, se aplica un parche idempotente al bin local (`--mention-only`):

- **Archivo del parche:** `$PREFIX/share/walkie/patch-mention-only.js` → target `~/.local/share/walkie/node_modules/walkie-sh/bin/walkie.js`. Backup `walkie.js.bak-mention`. Marcador idempotente `/* walkie-patch-mention */`.

Lo que añade:

1. **`--mention-only`** → responde solo si `@<nombre>` aparece en el mensaje.
2. **`--respond-to <id>`** → responde solo si `msg.from === <id>` (p. ej. un ejecutor que solo obedece al brain).
3. **Anti-replay (`START_TS`)** → descarta mensajes con `ts` anterior al arranque del agente; si el daemon se reinicia y reenvía historial, no re-procesa tareas viejas.

Desde el paquete `1.5.0-2` el `postinst` lo aplica automáticamente (STEP 2.5b). A mano (instalación por otra vía):

```bash
node $PREFIX/share/walkie/patch-mention-only.js \
  ~/.local/share/walkie/node_modules/walkie-sh/bin/walkie.js
```

## Seguimiento de miembros del canal (`--track-members`)

Un agente brain no ve quién entra al canal: descarta los anuncios `"X joined"` junto con los mensajes de sistema, y con varios ejecutores no sabe a quién delegar. Un tercer parche idempotente (`$PREFIX/share/walkie/patch-members.js`, corre después de `patch-agents.js` y `patch-mention-only.js`) añade el flag opt-in:

```bash
walkie agent ops:secret --cli claude --track-members --mention-only \
  --prompt "$(cat ~/.config/walkie/prompt-brain.txt)"
```

Lo que añade:

1. Registra **miembros locales** desde los anuncios `joined`/`left` del daemon + una consulta `members` al arrancar, y **peers remotos** (otros dispositivos) desde el `from` del primer mensaje de cada uno.
2. Inyecta el roster en el prompt del agente **solo cuando cambia la membresía** (Δ, sin ruido): `[ROSTER #channel] brain, exec1, humano, ...`
3. Persiste en `~/.walkie/roster-<canal>.json`, así un brain reiniciado ya nace conociendo quién está presente.

Desde el paquete `1.5.0-3` el `postinst` lo aplica en STEP 2.5c. A mano:

```bash
node $PREFIX/share/walkie/patch-members.js \
  ~/.local/share/walkie/node_modules/walkie-sh/bin/walkie.js
```

## Asistencia remota 1-a-1 (brain + ejecutor)

Para asistencia remota (admin + usuario dialogando, brain delegando y ejecutor aplicando en el dispositivo del usuario), lanza cada agente con su prompt y flags:

**Brain (dispositivo del admin)** — orquesta y delega, **nunca ejecuta**:

```bash
walkie agent soporte-u1 --secret SEcreto \
  --name termux-oracle-brain \
  --cli claude \
  --mention-only \
  --track-members \
  --prompt "$(cat ~/.config/walkie/prompt-brain.txt)"
```

> **Por qué `--cli claude` y no `--cli codex`:** el brain debe **orquestar y delegar**, nunca ejecutar en su propio dispositivo. `codex` es un agente tool-use con shell: aunque el prompt le prohíba ejecutar, tiene la capacidad física de hacerlo y a veces lo hace. `claude` se invoca en modo texto puro (`claude -p`, sin tools), así que al brain le es **imposible por construcción** ejecutar comandos.

**Ejecutor (dispositivo del usuario)** — el único que ejecuta:

```bash
walkie agent soporte-u1 --secret SEcreto \
  --name usuario1-executor \
  --cli codex \
  --mention-only \
  --respond-to termux-oracle-brain \
  --agent-args "--dangerously-skip-permissions" \
  --prompt "$(cat ~/.config/walkie/prompt-executor.txt)"
```

El brain delega con el formato `TASKID|ACCION|PARAMS` y el ejecutor responde `TASKID|ESTADO|RESULTADO`. El uso de `--mention-only` en el ejecutor es redundante con `--respond-to` pero añade defensa en profundidad.

## Instalación en Termux (⚠️ requiere parche)

`npm install -g walkie-sh` instala correctamente en Termux (las dependencias nativas `udx-native` y `sodium-native` traen prebuilds `android-arm64`), **pero el daemon no arranca en Android sin el parche**.

### El problema: SELinux bloquea netlink

Al iniciarse, el daemon crea un socket `AF_NETLINK` para observar cambios en las interfaces de red (`dht-rpc/lib/io.js` llama `udx.watchNetworkInterfaces()` incondicionalmente). En Android, SELinux bloquea el `bind()` sobre `netlink_route_socket` para apps no-root (`untrusted_app`), resultando en:

```
Error: permission denied
→ bind(AF_NETLINK) = EACCES
```

Es la misma limitación conocida de Go en Android (`net.Interfaces()`, golang issues #40569/#68082) y afecta a todas las apps Android 13+.

### El parche (sin root)

Editar `node_modules/udx-native/lib/network-interfaces.js` para envolver el init nativo en `try/catch` y degradar a `interfaces = []`:

```js
this.interfaces = []
try {
  binding.udx_napi_interface_event_init(...)
  this.interfaces = binding.udx_napi_interface_event_get_addrs(this._handle)
} catch (e) {
  this.interfaces = []
}
```

Con el parche, el daemon arranca y responde `status`, `connect`, `send`, `read`. **La IP local cae a `127.0.0.1`**, lo que solo desactiva el *atajo LAN* (emparejamiento de subredes) y la detección de cambios de red. El descubrimiento WAN (internet) sigue funcionando porque HiperDHT aprende la IP externa del paquete UDP de origen, no de la enumeración local.

**Nota**: el parche se pierde al reinstalar el paquete (`npm i -g` lo reescribe). Para packaging en i-HakLab se requeriría aplicarlo vía `postinstall`.

### Alternativa con root

```bash
su -c 'supolicy --live "allow untrusted_app_27 untrusted_app_27 netlink_route_socket bind"'
```

o deshabilitar SELinux (`setenforce 0`), que restaura el comportamiento completo (incluido el atajo LAN).

### Estado de la validación

- ✅ Instalación limpia en Termux (62 paquetes, deps nativas OK con prebuilds android-arm64).
- ✅ Daemon arranca con el parche; comandos `status/connect/send/read` funcionan (same-machine).
- ✅ Runner universal + Ollama validados end-to-end en i-Haklab: `walkie agent --cli ollama` responde vía P2P y mantiene contexto entre mensajes (recuerda el código secreto dado en un mensaje previo).
- ✅ `codex exec --skip-git-repo-check` validado fuera de un repo git (sin el flag falla con "Not inside a trusted directory").
- ✅ `walkie agent --cli cactus` validado end-to-end (v1.5.0-5): el agente responde vía P2P con la respuesta del modelo on-device leída de `--result-json` (canal limpio, sin framing del CLI).
- ⏳ **Pendiente**: validación P2P real entre dos dispositivos en redes distintas (WAN) y en LAN.

## Consideraciones adicionales

*   **Debug**: el daemon se lanza detached con `stdio:'ignore'` (los errores no salen a consola). Para ver fallos, ejecutar directamente `node node_modules/walkie-sh/src/daemon.js`; el log queda en `~/.walkie/daemon.log`.
*   **Memoria de conversación**: los agentes recuerdan contexto entre mensajes.
*   **Persistencia**: `--persist` sincroniza mensajes perdidos al reconectar.
*   **Incluye skill**: los agentes AI pueden instalarlo como skill y usarlo nativamente.
*   **Cross-platform**: macOS, Linux, Windows (y Android con el parche).
*   **En i-Haklab**: disponible como paquete `.deb` (`apt install walkie` / `pkg install walkie`). El `postinst` instala `walkie-sh` desde el repo git de upstream (v1.5.0, fallback npm 1.4.0 sin internet) y aplica ambos parches (netlink/SELinux + runner universal de agentes). El runner universal también genera wrappers idempotentes por agente en `~/.local/bin/` (con `WRAP_MARKER="# walkie agent wrapper"`), preservando los manuales (`codex`, `claude`) y omitiendo los que no son agentes (`ctx7`, `engram`, `smithery`).

---
*Nota: herramienta del ecosistema de agentes AI, incluida en el arsenal de paquetes de i-HakLab con parche de runner universal para agentes y soporte de IA local vía Ollama.*
