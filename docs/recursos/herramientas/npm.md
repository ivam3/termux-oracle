# npm (wrapper i-HakLab)

## ¿Qué es npm?

**npm** es el gestor de paquetes principal del ecosistema **Node.js**. Permite instalar dependencias locales de proyectos y herramientas globales de línea de comandos.

En **i-HakLab**, `npm` cuenta con un wrapper instalado en:

```bash
~/.local/bin/npm
```

El wrapper mantiene la compatibilidad con el binario real de Termux (`$PREFIX/bin/npm`), pero añade automatización para herramientas usadas por la suite.

## ¿Para qué es útil?

* Instalar herramientas CLI basadas en Node.js.
* Preparar dependencias especiales para herramientas como `n8n`.
* Normalizar alias de paquetes usados en i-HakLab.
* Ejecutar configuraciones posteriores mediante `pkg2conf`.
* Automatizar instalaciones globales desde menús o scripts.

## Comandos básicos

**Instalar dependencias locales de un proyecto:**

```bash
npm install
```

**Instalar una herramienta global:**

```bash
npm install -g paquete
```

**Actualizar paquetes globales:**

```bash
npm update -g
```

**Desinstalar un paquete global:**

```bash
npm uninstall -g paquete
```

## Automatizaciones del wrapper

El wrapper interviene en:

```bash
npm install ...   # también npm i y npm add
npm update ...    # también npm up y npm upgrade
npm uninstall ... # también npm remove, npm rm y npm un
```

Para el resto de comandos delega directamente al binario real:

```bash
$PREFIX/bin/npm "$@"
```

### Cómo procesa los argumentos

Desde i-HakLab v3.13.32 el wrapper separa **opciones** de **paquetes** antes
de invocar a npm:

* Cualquier opción (`-g`, `--global`, `--save-dev`, `--omit=dev`,
  `--registry=...`, etc.) se pasa intacta.
* El orden ya no importa: `npm install paquete -g` equivale a
  `npm install -g paquete`.
* Varios paquetes se instalan en **una sola** llamada.
* Las opciones con valor separado (`--registry URL`, `--omit dev`) se
  conservan completas; las que usan `--flag=valor` también.
* `npm install` sin paquetes dentro de un proyecto instala sus dependencias
  (antes el wrapper no hacía nada).
* `npm install -g` sin paquete muestra un error de uso en lugar de intentar
  instalar el directorio actual.
* El wrapper ya **no cambia el directorio de trabajo** a `$HOME`, por lo que
  las instalaciones locales apuntan al proyecto correcto.
* Los alias se normalizan también al desinstalar.

Si el paquete es `pnpm` u `open-lovable`, el wrapper ejecuta su flujo especial
y no los incluye en la llamada genérica.

## Alias normalizados

Cuando instalas, actualizas o desinstalas ciertas herramientas, el wrapper traduce nombres cortos al paquete real:

| Alias usado | Paquete real |
|---|---|
| `gemini-cli` | `@google/gemini-cli` |
| `qwen-code` | `@qwen-code/qwen-code` |
| `claude-code` | `@anthropic-ai/claude-code` |
| `codex` | `@mmmbuto/codex-cli-termux@latest` |
| `copilot-cli` / `github-copilot` | `@github/copilot` |
| `minimax-cli` | `mmx-cli` |
| `testsprite` | `@testsprite/testsprite-mcp` |
| `zcode-cli` | `zcode-app-cli` |
| `openspec` | `@fission-ai/openspec` |
| `sleepwalker` | `@sleepwalkerai/cli` |
| `kimi-code` | `@moonshot-ai/kimi-code` |
| `context7` | `ctx7` |
| `comandle` | `github.com/legiosai/comandle@latest` |
| `smithery` | `@smithery/cli` |

Ejemplo:

```bash
npm install -g gemini-cli
```

se convierte en:

```bash
npm install -g @google/gemini-cli
```

## Instalación especial de n8n

Al instalar `n8n`, el wrapper prepara el entorno de Termux antes de llamar a npm:

1. Instala dependencias del sistema:

```bash
apt install nodejs-lts libsqlite sqlite
```

2. Instala herramientas globales necesarias para compilación y ejecución:

```bash
npm install -g pm2 gyp node-gyp
```

3. Crea directorios de configuración:

```bash
mkdir -p ~/.n8n ~/.gyp
```

4. Genera `~/.gyp/include.gypi` con una configuración compatible con Android/Termux.

Uso recomendado:

```bash
npm install -g n8n
```

## Instalación especial de pnpm

Si instalas `pnpm` desde npm, el wrapper ejecuta:

```bash
corepack enable
PNPM_CONFIG_PACKAGE_IMPORT_METHOD=copy pnpm setup --force --no-modify-path
pnpm config set package-import-method copy --global
```

La importación por copia es necesaria porque SELinux en Android rechaza los
enlaces duros del almacén de pnpm. `--no-modify-path` evita que `pnpm setup`
altere el `PATH` del shell; el directorio `~/.local/share/pnpm/bin` ya está
contemplado por i-HakLab. npm no sobrescribe el shim de Corepack en
`$PREFIX/bin/pnpm`.

## Instalación especial de open-lovable

Para `open-lovable`, el wrapper elimina una instalación previa si existe, clona el repositorio en:

```bash
~/.local/share/open-lovable
```

y ejecuta la instalación desde esa ruta con `corepack` habilitado.

## Configuración posterior con pkg2conf

Tras instalar paquetes compatibles, el wrapper llama a:

```bash
bash ~/.local/libexec/pkg2conf nombre-del-paquete
```

Esto aplica integraciones de i-HakLab para herramientas como:

```text
@google/gemini-cli, @qwen-code/qwen-code, @anthropic-ai/claude-code,
@github/copilot, n8n, localtunnel, open-lovable, zcode-app-cli,
@testsprite/testsprite-mcp
```

## Notas importantes

* Para herramientas CLI se recomienda usar `-g` o `--global`.
* `npm update -g` actualiza herramientas globales según las restricciones semver permitidas.
* El wrapper delega al npm real de Termux cuando el comando no es instalar, actualizar o desinstalar.
* `npm install -g zcode-cli` instala el CLI de ZCode como `zcode-cli`; la app
  gráfica `zcode` no se toca (ver `zcode-cli.md`).
* Si ves errores de árbol global, diagnostica con `npm ls -g --depth=0`.

