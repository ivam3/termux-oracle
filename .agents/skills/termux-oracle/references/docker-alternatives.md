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
| Característica | udocker | termux-docker-qemu | proot |
|---------------|---------|-------------------|-------|
| Root real | ❌ | ✅ (dentro de la VM) | ❌ |
| Contenedores Docker | ✅ | ✅ (dentro de la VM) | ❌ |
| Rendimiento | Alto | Bajo (emulación QEMU) | Medio |
| Instalación | `pkg install udocker` | `pkg install termux-docker-qemu` | Nativo |
| Complejidad | Baja | Media | Baja |
| Uso recomendado | Contenedores ligeros | Tareas que requieren root real | Entorno Linux básico |
