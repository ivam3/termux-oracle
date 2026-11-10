# zcode-cli (ZCode CLI)

## ¿Qué es zcode-cli?

**`zcode-cli`** es el cliente de terminal del agente de IA **ZCode** (Z.AI):
permite conversar con el modelo GLM, pedirle que escriba o modifique código y
usar comandos y plugins sin abrir la aplicación gráfica.

Es un paquete npm (`zcode-app-cli`), no un binario glibc: funciona en Termux
puro, sin `termux-x11` ni Electron. i-HakLab lo instala con el nombre
**`zcode-cli`** para no chocar con el wrapper de escritorio `zcode`.

> Para la app gráfica Electron y su port a Termux, ver `zcode.md`.

## ¿Para qué es útil?

* Programar asistido por IA desde la terminal.
* Consultas puntuales sin abrir interfaz (`--prompt`).
* Trabajar con el modelo GLM de Z.AI o el trial de BigModel.
* Convivir con la app `zcode` instalada como binario glibc.

## Instalación

**Con i-HakLab:**

```bash
npm install -g zcode-cli
```

El wrapper de npm traduce `zcode-cli` → `zcode-app-cli` y ejecuta la
pre-configuración de `pkg2conf`.

**Sin i-HakLab (replicable):**

```bash
npm install -g zcode-app-cli
termux-fix-shebang "$PREFIX/lib/node_modules/zcode-app-cli/bin/zcode.js"
ln -sf ../lib/node_modules/zcode-app-cli/bin/zcode.js "$PREFIX/bin/zcode-cli"
```

Requisito: **Node.js 22 o superior**. i-HakLab verifica la versión e instala
`nodejs-lts` si hace falta.

## Primeros pasos

1. Abrir la interfaz:

   ```bash
   zcode-cli
   ```

2. Guardar la API key (una sola vez):

   ```bash
   i-Haklab setapikey   # elegir zcode (o bigmodel)
   ```

   También se puede pegar a mano con `/login` → **Z.AI Coding Plan API Key**
   (el login por navegador solo funciona en macOS). La primera vez se abre un
   asistente; `/setup` lo reabre.

3. Probar un prompt directo:

   ```bash
   zcode-cli --prompt "hola, ¿qué puedes hacer?" --no-browser
   ```

## Comandos más usados

| Comando | Para qué sirve |
|---|---|
| `zcode-cli` | Abre la interfaz de terminal |
| `zcode-cli --prompt "..." --no-browser` | Una sola pregunta sin abrir la interfaz |
| `zcode-cli --help` | Ayuda y opciones |
| `zcode-cli --version` | Versión instalada |
| `zcode-cli doctor` | Diagnóstico del entorno |
| `zcode-cli plugins list` | Plugins disponibles |

Dentro de la interfaz: `/help`, `/login`, `/logout`, `/model`, `/resume`,
`/status`, `/copy`, `/cls`.

## Automatización de i-HakLab (`pkg2conf`)

Al instalar `zcode-cli`, i-HakLab aplica estas correcciones:

1. **Shebang:** repara el `#!/usr/bin/env node` con `termux-fix-shebang`.
2. **Hardlinks (EACCES):** algunas versiones crean `config.json` con
   `tmp + link()`; Android/F2FS rechaza los hardlinks, así que el wrapper
   parchea esa llamada a `rename()`.
3. **Colisión de binarios:** si npm crea `$PREFIX/bin/zcode` apuntando al CLI,
   lo renombra a `zcode-cli`; el wrapper de escritorio `zcode` no se toca.
4. **Configuración inicial:** si no existe, siembra
   `~/.zcode/cli/config.json` desde `config.example.json` con modo `600`.
5. **API key:** mueve `options.apiKey` al nivel superior del proveedor (el
   runtime solo lee esa posición) e inyecta `APIKEY_zcode` desde
   `i-Haklab setapikey` sin sobrescribir una clave existente.
6. **Prueba de cuota:** lanza un micro-prompt headless y clasifica el estado
   de la cuenta (saldo, key rechazada, sin configurar o todo listo).

## Saldo y planes

* **Coding Plan es de pago** (desde ~$18/mes); la key del CLI gasta de ese plan.
* **El plan free vive en la app de escritorio** (Start Plan por OAuth) y no se
  puede pasar al CLI.
* `[1113] Insufficient balance` = la instalación funciona; la cuenta no tiene
  saldo. Recargar en <https://z.ai/manage-apikey/billing> o usar el **trial
  gratis de BigModel**: key en <https://open.bigmodel.cn/usercenter/apikeys> →
  `i-Haklab setapikey` → `bigmodel` → `/login` → **BigModel Coding Plan API Key**.
* **401 / auth error** = key inválida o revocada; regenérala y repite
  `i-Haklab setapikey` → `zcode`.

## Uso desde Neovim (CodeCompanion)

La configuración de i-HakLab define el adapter `zcode`
(`openai_compatible` contra `https://open.bigmodel.cn/api/paas/v4`, modelo
`glm-4.5-air`) y lee `APIKEY_zcode` del entorno:

```vim
:CodeCompanionChat adapter=zcode
```

No requiere el binario `zcode-cli`: habla directo con la API por HTTP.

## Notas importantes

* `~/.zcode/cli/` guarda ajustes, sesiones e historial.
* Añade `--no-browser` a los prompts directos si no necesitas control del navegador.
* `/paste-image` y algunas funciones de documentos pueden no estar disponibles
  en el teléfono; el resto funciona normal.
* i-HakLab documenta el CLI también en `i-Haklab about zcode-cli`.

---
*Nota: ZCode integra los modelos GLM en el ecosistema i-Haklab como CLI npm y como app gráfica nativa glibc.*
