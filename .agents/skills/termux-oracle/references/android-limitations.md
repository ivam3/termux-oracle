# Android Limitations Reference

## Bionic vs glibc
- Android usa **Bionic libc**, no GNU glibc
- Los binarios Linux precompilados fallan con `CANNOT LINK EXECUTABLE` o `segfault`
- Solución 1: **Paquetes compilados para Termux** (repositorios oficiales y termux-packages)
- Solución 2: **Adaptación glibc** (patrón .va39 + wrapper C + loader glibc)
  - Usado por: `claude-code`, `opencode`, `codebuff`, `freebuff`, `mimocode`, `mistral-vibe`
  - El binario real se renombra a `.va39` y se envuelve con un loader que apunta a `$PREFIX/glibc/lib/ld-linux-aarch64.so.1`

## Sin root por defecto
- Termux corre como app de usuario Android sin permisos root
- Limitaciones: no montar filesystems, no abrir puertos <1024, no modificar `/system`
- Alternativas:
  - **Fake root**: `proot` (reescribe syscalls, útil pero limitado)
  - **VM real**: `termux-docker-qemu` (Alpine Linux vía QEMU, root real)
  - **Contenedores**: `udocker` (Docker userspace sin root)
  - **ADB**: controlar el dispositivo desde Termux vía depuración inalámbrica

## Almacenamiento
- Directorio privado: `/data/data/com.termux/files/home/`
- Almacenamiento compartido: `/sdcard/` o `/storage/emulated/0/`
- Ejecutar `termux-setup-storage` para enlazar almacenamiento externo

## Proot
- Crea un directorio raíz falso sin necesidad de root real
- Usado por `i-HakLab pd <distro>` para ejecutar distribuciones Linux
- Limitaciones: ciertas syscalls no pasan, rendimiento reducido, no hay acceso real a dispositivos

## ADB (instalable con `pkg install android-tools`)
- Permite ejecutar comandos en el sistema Android subyacente
- Requiere activar Opciones de desarrollador:
  1. Ajustes → Acerca del dispositivo → Número de compilación (pulsar 7 veces)
  2. Ajustes → Opciones de desarrollador → Depuración USB / Depuración inalámbrica
- **Emparejamiento inalámbrico** (`adb pair`): Android 11+, código PIN de 6 dígitos
- **Método clásico**: Android 10-, requiere conexión USB inicial, luego `adb tcpip 5555`
- Para guía visual completa: `i-haklab show tutorials` → "termux tips cap 14"
