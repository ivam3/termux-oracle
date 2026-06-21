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

El wrapper interviene principalmente en:

```bash
npm install ...
npm update ...
npm uninstall ...
```

Para otros comandos, delega directamente al binario real:

```bash
$PREFIX/bin/npm "$@"
```

## Alias normalizados

Cuando instalas o actualizas ciertas herramientas, el wrapper traduce nombres cortos al paquete real:

| Alias usado | Paquete real |
|---|---|
| `gemini-cli` | `@google/gemini-cli` |
| `qwen-code` | `@qwen-code/qwen-code` |
| `claude-code` | `@anthropic-ai/claude-code` |
| `codex` | `@mmmbuto/codex-cli-termux@latest` |
| `copilot-cli` / `github-copilot` | `@github/copilot` |
| `minimax-cli` | `mmx-cli` |

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
pnpm setup
```

También intenta asegurar que el directorio de binarios de pnpm quede disponible en la configuración del shell:

```bash
~/.local/share/pnpm/bin
```

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
@github/copilot, n8n, localtunnel, open-lovable
```

## Notas importantes

* Para herramientas CLI se recomienda usar `-g` o `--global`.
* `npm update -g` actualiza herramientas globales según las restricciones semver permitidas.
* El wrapper siempre termina delegando al npm real de Termux cuando corresponde.

