# Docker Alternatives for Termux

En Termux no se puede ejecutar Docker directamente (requiere kernel features no disponibles sin root). Alternativas:

## udocker (recomendado para contenedores)
- **Package:** `pkg install udocker` (desde ivam3/termux-packages)
- **Qué es:** Ejecuta contenedores Docker en espacio de usuario sin root
- **Cómo funciona:** Usa `proot` o `popen` para simular el aislamiento de contenedores
- **Uso:** Similar a Docker CLI (`udocker run`, `udocker pull`, etc.)
- **Ventaja:** No requiere kernel features, funciona 100% en espacio de usuario

## termux-docker-qemu (recomendado para root real)
- **Package:** `pkg install termux-docker-qemu` (desde ivam3/termux-packages)
- **Qué es:** Crea una máquina virtual con Alpine Linux vía QEMU
- **Para qué:** Obtener un usuario **root real** (no proot) en Android no rooteado
- **Cómo funciona:** Emula la arquitectura del procesador con QEMU, ejecuta Alpine Linux
- **Docker dentro:** Una vez dentro de la VM Alpine, puedes instalar Docker real
- **Uso:** `termux-docker-qemu` automatiza la creación e inicio de la VM
- **Modo gráfico X11:**
  - `termux-docker-qemu <os> x11 sdl` — arranca con termux-x11 + xfwm4 + VirtIO-GPU 3D (virgl), con resolución dinámica.
  - `termux-docker-qemu <os> x11 tcp` — modo ultra ligero vía `socat` TCP:6000 -> `/tmp/.X11-unix/X0`. QEMU en `-nographic`, envía comandos X11 directo al host (ver `references/termux-x11.md`).

## proroot (reemplazo directo de proot — sin ptrace)
- **Package:** `pkg install proroot` (desde ivam3/termux-packages)
- **Qué es:** Rootless Linux runtime. Usa LD_PRELOAD + parcheo ELF en vez de ptrace
- **Cómo funciona:** Intercepta syscalls dentro del mismo proceso (sin cambios de contexto)
- **Uso:** `proroot /bin/sh -c 'comando'` (auto-detecta rootfs Ubuntu 24.04)
- **Rootfs:** Ubuntu 24.04 (glibc 2.39) en `$PREFIX/var/lib/proot-distro/containers/proroot/rootfs/`
- **Ventaja:** Rendimiento casi nativo. Node.js, Chromium headless, Python glibc sin cuello de botella
- **Limitaciones:** Solo arm64. glibc > 2.39 no soportado. Código cerrado.

## proot (ligero pero limitado)
- **Qué es:** Reescribe syscalls para simular un directorio raíz falso
- **Package:** Viene con Termux, también `proot-distro` para distribuciones
- **Uso:** `i-HakLab pd alpine` o `proot-distro install ubuntu`
- **Limitaciones:** No es root real, ciertas apps no funcionan, rendimiento reducido

### proot-distro para agentes AI (método legacy)
Antes de la adaptación glibc nativa, los agentes como `opencode` y `claude-code` se ejecutaban dentro de **Alpine Linux** vía `proot-distro`. Aún útil para ciertos casos:

```bash
# Instalar Alpine en proot
proot-distro install alpine

# Ejecutar comando dentro de Alpine
proot-distro login alpine -- <comando>

# Ejecutar opencode dentro de Alpine (método legacy)
proot-distro login alpine -- opencode
```

**Ventajas del método legacy proot:**
- Funciona en cualquier arquitectura (no solo aarch64)
- No requiere compilar helpers C ni tener glibc
- Aislamiento completo del entorno Termux

**Desventajas vs glibc nativo:**
- Rendimiento reducido (overhead de proot)
- Problemas con señales y procesos hijos
- No hay integración directa con el sistema de archivos de Termux
- Mayor latencia en cada invocación

## Comparativa
| Característica | udocker | termux-docker-qemu | proot | proroot |
|---------------|---------|-------------------|-------|---------|
| Root real | ❌ | ✅ (dentro de la VM) | ❌ | ❌ |
| Contenedores Docker | ✅ | ✅ (dentro de la VM) | ❌ | ❌ |
| Rendimiento | Alto | Bajo (emulación QEMU) | Medio | Alto (casi nativo) |
| Overhead por syscall | Variable | Alto | 2 cambios contexto | 0 (en-proceso) |
| Arquitecturas | Todas | Todas | Todas | Solo arm64 |
| Node.js/Chromium | Limitado | Lento | Lento | ✅ Fluido |
| Instalación | `pkg install udocker` | `pkg install termux-docker-qemu` | Nativo | `pkg install proroot` |
| Complejidad | Baja | Media | Baja | Baja |
| Código fuente | Abierto | Abierto | Abierto (GPL) | Cerrado (binarios gratis) |
| Uso recomendado | Contenedores ligeros | Tareas que requieren root real | Entorno Linux básico | Entorno Linux glibc pesado (Node, Chromium, Python) |
