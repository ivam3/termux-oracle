# OpenCode CLI (opencode-ai)

## ¿Qué es OpenCode CLI?

**OpenCode CLI** es un agente de programación de código abierto y agnóstico de modelos, diseñado para la terminal. A diferencia de otras herramientas, permite utilizar casi cualquier proveedor de IA (OpenAI, Anthropic, Google Gemini, Groq, o modelos locales) para asistir en el desarrollo, depuración y análisis de código directamente desde una interfaz de terminal (TUI) moderna y fluida.

## ¿Para qué es útil la herramienta?

OpenCode CLI destaca por su versatilidad y seguridad en el flujo de trabajo:

*   **Agentes Especializados:**
    *   **Plan Mode:** Un agente de solo lectura ideal para explorar arquitecturas y proponer estrategias sin riesgo de modificar archivos.
    *   **Build Mode:** Un agente con permisos de escritura capaz de implementar funciones, refactorizar y corregir errores tras tu aprobación.
*   **Agnóstico de Modelos:** Soporta múltiples proveedores simultáneamente mediante configuración de API Keys o protocolos como **MCP (Model Context Protocol)** para extender sus habilidades con herramientas externas.
*   **Integración con LSP y Git:** Capacidad nativa para interactuar con servidores de lenguaje (LSP) para detectar errores de sintaxis y gestionar ramas o commits de Git de forma inteligente.
*   **Seguridad y Control:** Incluye comandos como `/undo` y `/redo` para revertir o reaplicar cambios realizados por la IA de manera instantánea.

## Instalación

OpenCode puede instalarse en Termux mediante dos métodos. Se recomienda el método **nativo glibc** por su rendimiento y estabilidad.

### Opción recomendada: Nativo glibc (vía termux-packages)
```bash
# Requiere tener agregado el repositorio ivam3/termux-packages
apt install opencode
```
Esto descarga el binario oficial de OpenCode (Bun-based) y lo adapta con:
- **Loader glibc**: ejecuta el binario real mediante `$PREFIX/glibc/lib/ld-linux-aarch64.so.1`
- **Wrapper C** (`opencode_helper.c`): limpia `LD_PRELOAD`, configura SSL y lanza el cargador
- **Binario real renombrado**: `$PREFIX/share/opencode/opencode.real`

**Ventajas**: sin Node.js, sin proot, ejecución directa con máximo rendimiento.
**Dependencias**: `glibc`, `clang`, `python`, `jq`, `curl`, `tar`.
**Arquitectura**: solo `aarch64`.

### Opción alternativa: Node.js (vía npm/pnpm)
```bash
# Mediante el wrapper de i-HakLab (redirige a npm):
apt install opencode
# O directamente:
npm install -g opencode-ai
pnpm install -g opencode-ai
```
Instala OpenCode como paquete Node.js. Funciona sin adaptación glibc pero requiere Node.js runtime.

### Opción alternativa: Bun (vía instalador oficial)
```bash
curl -fsSL https://opencode.ai/install | bash
```
Requiere configuración adicional con `glibc-runner`:
```bash
pkg install glibc glibc-runner glibc-repo
grun ~/.local/share/bun/bin/bun opencode
```

### Opción legacy: proot-distro (ya no recomendada)
Antes de la adaptación nativa, opencode se ejecutaba dentro de **Alpine Linux** via proot-distro:
```bash
proot-distro install alpine
proot-distro login alpine -- opencode "$@"
```
Este método fue reemplazado por el nativo glibc (helper.c + loader). Los paquetes actuales de ivam3/termux-packages ya no usan proot.

## Funcionamiento interno (openconde\_helper)

El método nativo glibc funciona con una arquitectura de 2 capas:

```
Termux (Bionic libc)
┌──────────────────────────────────────────────────────┐
│  $PREFIX/bin/opencode   ← Android PIE (7KB)          │
│       │                                              │
│       │ execv(ld.so, --library-path, ..., opencode.real) │
│       ▼                                              │
│  /usr/glibc/lib/ld-linux-aarch64.so.1  ← glibc linker│
│       │                                              │
│       │ carga + enlaza                               │
│       ▼                                              │
│  ~/.local/share/opencode/opencode.real  ← binario    │
│    (180MB, ELF glibc, parcheado en opcodes)          │
└──────────────────────────────────────────────────────┘
```

### Paso a paso

1. **Usuario ejecuta `opencode`**: el kernel de Android ve un ELF con intérprete `/system/bin/linker64` (Bionic) — lo carga normalmente.

2. **Limpieza del entorno** (`opencode_helper.c`):
   - `unsetenv("LD_PRELOAD")` — evita que librerías Bionic se inyecten en glibc
   - `unsetenv("LD_LIBRARY_PATH")` — mismo motivo
   - `setenv("GODEBUG", "netdns=cgo")` — fuerza resolución DNS vía C, no Go puro
   - `setenv("SSL_CERT_FILE", ...)` — apunta a certificados de Termux

3. **Construcción del argv**: el helper construye:
   ```
   argv = [ld.so, --library-path, /usr/glibc/lib, opencode.real, args...]
   ```

4. **`execv(ld.so, ...)`**: ejecuta el cargador de glibc directamente, NO el binario real. Esto evita que el kernel busque `/lib/ld-linux-aarch64.so.1` (que no existe en Android).

5. **El linker glibc** carga `opencode.real`: mapea segmentos ELF, resuelve dependencias (`libc.so.6`, etc.) desde `--library-path`, y salta al punto de entrada.

### Parche de opcodes (kernel Android)

Además del helper, el binario `opencode.real` se parchea a nivel de código máquina para redirigir syscalls bloqueadas por el kernel Android:

| Syscall original | Reemplazo | Motivo |
|---|---|---|
| `epoll_pwait2` (441) → `epoll_wait` (20) | Sustitución de opcode | No implementada en kernel 5.10 |
| `faccessat2` (439) → `faccessat` (29) | Sustitución de opcode | Bloqueada por seccomp en Android 14+ |
| `clone3` (435) | Forzar error | Para que Go use `clone()` tradicional |
| `memfd_create` (279) | Forzar error | Prohibido por SELinux |

**¿Por qué no sirve LD_PRELOAD aquí?**: Bun/OpenCode emiten syscalls directas (`svc #0` en ARM64), no llaman a funciones de glibc como `open()`. LD_PRELOAD solo intercepta funciones de glibc, no syscalls directas. La única forma de redirigirlas es modificar el código máquina del binario.

### Archivos involucrados

| Ruta | Rol |
|---|---|
| `$PREFIX/bin/opencode` | ELF Android (7KB) — helper compilado |
| `$PREFIX/share/opencode/opencode_helper.c` | Código fuente del helper |
| `~/.local/share/opencode/opencode.real` | Binario glibc real (180MB) |
| `/usr/glibc/lib/ld-linux-aarch64.so.1` | Cargador glibc (236KB) |
| `/usr/glibc/lib/libc.so.6` | Librería glibc |

### Código del helper

```c
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>

int main(int argc, char** argv) {
    unsetenv("LD_PRELOAD");
    unsetenv("LD_LIBRARY_PATH");
    setenv("GODEBUG", "netdns=cgo", 1);
    setenv("SSL_CERT_FILE",
        "/data/data/com.termux/files/usr/etc/tls/cert.pem", 1);

    char* loader = "/data/data/com.termux/files/usr/glibc/lib/ld-linux-aarch64.so.1";
    char real_bin[] = "/data/data/com.termux/files/home/.local/share/opencode/opencode.real";
    char lib_path[] = "/data/data/com.termux/files/usr/glibc/lib";

    char** new_argv = malloc((argc + 4) * sizeof(char*));
    new_argv[0] = loader;
    new_argv[1] = "--library-path";
    new_argv[2] = lib_path;
    new_argv[3] = real_bin;
    for (int i = 1; i < argc; i++)
        new_argv[i + 3] = argv[i];
    new_argv[argc + 3] = NULL;

    execv(loader, new_argv);
    perror("execv");
    return 1;
}
```

## ¿Cómo se usa? (Ejemplos básicos)

Una vez instalado, puedes usarlo así:

**Ejemplo 1: Iniciar la interfaz interactiva (TUI)**

```bash
opencode
```
*(Usa la tecla `Tab` para alternar entre el modo Plan y Build).*

**Ejemplo 2: Inicializar un proyecto con contexto**

```bash
opencode /init
```
*(Crea un archivo `AGENTS.md` que ayuda a la IA a entender la estructura y reglas de tu repositorio).*

**Ejemplo 3: Ejecutar una tarea rápida desde la línea de comandos**

```bash
opencode run "Crea una función en Python para validar direcciones IP"
```

## Consideraciones Adicionales

*   **Autenticación:** Configura tus proveedores fácilmente con `opencode auth login`.
*   **Extensibilidad:** Soporta el protocolo **MCP**, permitiendo que la IA use herramientas externas (buscadores, bases de datos, etc.).
*   **Integración con GitHub:** Permite automatizar el triaje de *issues* y la creación de Pull Requests mediante GitHub Actions.
*   **Privacidad:** Al ser compatible con modelos locales (vía Ollama u otros), puedes procesar código sensible sin que este salga de tu máquina.

---
*Nota: Esta herramienta integra la versatilidad de los agentes de código abierto y multi-proveedor en el ecosistema i-Haklab.*
