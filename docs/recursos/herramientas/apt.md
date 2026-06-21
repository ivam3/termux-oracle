# apt (wrapper i-HakLab)

## ¿Qué es apt?

**apt** es el gestor de paquetes usado en Termux para instalar, actualizar, buscar y eliminar paquetes del sistema. En el entorno **i-HakLab** no se ejecuta directamente: existe un **wrapper** en:

```bash
~/.local/bin/apt
```

Este wrapper intercepta comandos como `apt install`, `apt reinstall` y `apt search` para decidir si la herramienta solicitada debe instalarse con el gestor nativo de Termux o con otro ecosistema como **pip**, **npm** o **gem**.

## ¿Para qué es útil?

* Instalar paquetes nativos de Termux.
* Automatizar dependencias posteriores a la instalación con `pkg2conf`.
* Redirigir herramientas que no son paquetes APT hacia el instalador correcto.
* Evitar instalaciones fallidas cuando una herramienta pertenece a Python, Node.js o Ruby.

## ¿Cómo funciona en i-HakLab?

Cuando ejecutas:

```bash
apt install herramienta
```

el wrapper revisa el nombre de la herramienta:

* Si es un **módulo Python**, sugiere y puede ejecutar:

```bash
python3 -m pip install herramienta
```

* Si es una **gema Ruby**, sugiere y puede ejecutar:

```bash
gem install herramienta
```

* Si es un **módulo Node.js**, sugiere y puede ejecutar:

```bash
npm install -g herramienta
```

* Si es un paquete normal de Termux, delega al binario real:

```bash
$PREFIX/bin/apt install herramienta
```

## Herramientas redirigidas por el wrapper

### Python / pip

El wrapper redirige herramientas como:

```text
bloodhound, frida, h8mail, hashid, holehe, mvt, objection,
octosuite, orbitaldump, osrframework, phoneintel, scrapy,
shodan, snscrape, speedtest-cli, sqlmap, wfuzz
```

### Ruby / gem

```text
bettercap, aquatone
```

### Node.js / npm

```text
bash-obfuscate, codex, copilot-cli, gemini-cli, localtunnel,
minimax-cli, n8n, pnpm, open-lovable, qwen-code, twifo-cli
```

También normaliza algunos alias antes de instalar:

| Alias usado | Paquete real |
|---|---|
| `gemini-cli` | `@google/gemini-cli` |
| `qwen-code` | `@qwen-code/qwen-code` |
| `codex` | `@mmmbuto/codex-cli-termux@latest` |
| `copilot-cli` / `github-copilot` | `@github/copilot` |
| `minimax-cli` | `mmx-cli` |

> Nota: el wrapper también contiene la normalización interna de `claude-code` a `@anthropic-ai/claude-code`, pero en este flujo debe instalarse preferentemente desde `npm` o `pnpm`.

## Comandos básicos

**Instalar un paquete nativo:**

```bash
apt install nmap
```

**Buscar una herramienta:**

```bash
apt search sqlmap
```

**Reinstalar:**

```bash
apt reinstall nmap
```

**Instalar una herramienta Node.js mediante el flujo automatizado:**

```bash
apt install n8n
```

En este caso el wrapper avisa que `n8n` es un módulo Node.js y ofrece ejecutar:

```bash
npm install -g n8n
```

## Automatización posterior con pkg2conf

Después de instalar o reinstalar paquetes, el wrapper comprueba si la herramienta aparece en:

```bash
~/.local/etc/i-Haklab/Tools/listofpkg2conf
```

Si aparece, ejecuta:

```bash
bash ~/.local/libexec/pkg2conf nombre-del-paquete
```

Esto permite aplicar configuraciones especiales, enlaces simbólicos, funciones de shell o ajustes necesarios para que la herramienta quede lista dentro de i-HakLab.

## Notas importantes

* El wrapper conserva compatibilidad con `apt` real delegando en `$PREFIX/bin/apt`.
* No fuerza la instalación redirigida sin confirmación: pregunta antes de ejecutar el gestor alternativo.
* Es especialmente útil cuando se instala desde menús o scripts de automatización, porque reduce errores de “paquete no encontrado”.
