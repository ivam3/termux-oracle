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
| `ollama` | REST API (sin CLI) |
| cualquier otro | `<cli> <prompt>` (fallback genérico) |

### Ollama (IA local)

Requiere un servidor Ollama en `http://127.0.0.1:11434` (configurable con `OLLAMA_HOST`). El runner usa la **REST API `/api/chat` con `stream:false`** (JSON limpio) mediante `fetch` nativo (Node ≥ 24), NO el CLI `ollama run` (en no-TTY escupe ANSI del spinner y es inservible).

Resolución de modelo: `--model` → `OLLAMA_MODEL` → primer modelo local de `/api/tags` (ignora los `:cloud`) → `qwen2.5-coder:1.5b`.

Mantiene **historial rodante** en memoria (últimos 40 mensajes) para dar contexto entre mensajes; validado end-to-end (el agente recuerda datos de mensajes previos).

### `--skip-git-repo-check`

Flag nativo de `walkie agent` que solo se reenvía a `codex` (añade `--skip-git-repo-check` a `codex exec`). Agentes que no lo soportan (p. ej. `agy`) lo ignoran — walkie no se lo pasa. Sin él, codex en un directorio no-git falla con *"Not inside a trusted directory and --skip-git-repo-check was not specified"*.

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
