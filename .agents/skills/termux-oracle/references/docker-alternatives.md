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

## Comparativa
| Característica | udocker | termux-docker-qemu | proot |
|---------------|---------|-------------------|-------|
| Root real | ❌ | ✅ (dentro de la VM) | ❌ |
| Contenedores Docker | ✅ | ✅ (dentro de la VM) | ❌ |
| Rendimiento | Alto | Bajo (emulación QEMU) | Medio |
| Instalación | `pkg install udocker` | `pkg install termux-docker-qemu` | Nativo |
| Complejidad | Baja | Media | Baja |
| Uso recomendado | Contenedores ligeros | Tareas que requieren root real | Entorno Linux básico |
