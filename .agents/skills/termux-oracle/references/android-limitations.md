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

## Bypass /proc/net via ADB shell (readproc) — patrón replicable sin root

- **Problema**: Desde Android 10, SELinux bloquea a `untrusted_app` (`u:r:untrusted_app:s0:c...`, uid `u0_aXXX`) el acceso a `/proc/net/{tcp,tcp6,udp,udp6,dev}` → `cat /proc/net/tcp: Permission denied`. `ss` falla con `Cannot open netlink socket: Permission denied`, `netstat` sin soporte. Es el mismo bloqueo que impide `netstat`/`ss` nativo en Termux.
- **Principio del bypass (no requiere i-HakLab, replicable por cualquier agente)**: `adb shell` corre como `uid=2000(shell)` `u:r:shell:s0` con grupos `readproc(3009)`, `inet(3003)`, `net_bw_stats(3006)` → **sí** puede `cat /proc/net/tcp` (69 líneas), `ss -tun` parcial y `dumpsys`. Termux (`pkg install android-tools`) puede auto-conectarse vía `adb connect 192.168.1.X:PORT` y usar `adb -s SERIAL shell` como puente. Patrón mínimo sin dependencias:
  ```bash
  pkg install android-tools
  adb devices # debe mostrar device
  adb -s SERIAL shell cat /proc/net/tcp  # vs cat /proc/net/tcp → Permission denied en Termux
  adb -s SERIAL shell cat /proc/net/tcp6
  adb -s SERIAL shell "cat /proc/net/tcp; cat /proc/net/tcp6" | awk '...hex2dec...decode_ip...'
  # escribir en ~/.local/share desde shell (sin permiso) → run-as o fallback
  adb shell mkdir -p /data/local/tmp/traffic 2>/dev/null || true
  adb shell run-as com.termux mkdir -p ~/.local/share/traffic 2>/dev/null || true
  ```
  Para cualquier `/proc` bloqueado por `untrusted_app`, probar `adb shell cat /proc/...` antes de asumir root. `run-as com.termux` permite escribir en `~/.local/share` desde `shell` si `FALLBACK=/data/local/tmp/traffic` no basta.
- **Ejemplo de implementación completa en i-HakLab (si `detect-env.sh` reporta `ihaklab_installed=true`, usar directamente; si no, replicar el patrón anterior)**: `~/.local/bin/net-traffic-scan` (`~/.local/share/traffic`, `FALLBACK=/data/local/tmp/traffic`):
  - Valida `adb devices` (`>1` → `select` con `adb -s`), si `0` → `warn` depuración inalámbrica.
  - `adb push net-traffic-scan.sh /data/local/tmp/ && adb shell chmod +x && adb shell "nohup sh /data/local/tmp/net-traffic-scan.sh &"`
  - Payload `sh` en device lee `/proc/net/tcp`+`tcp6` y `udp`+`udp6` con `awk` `hex2dec`+`rev8`+`decode_ip` (IPv4-mapped `::ffff:` → IPv4, IPv6 nativo `xxxx:xxxx:...`), filtra `127.0.0.1` y `adb 5555/5037`, cachea `pm list packages --uid` en `/data/local/tmp/.net_cache`, escribe `~/.local/share/traffic/network_activity.txt` (grid Unicode `┌ ─ │`) y `ips_24h_*.txt` con migración plain→grid.
  - Wrapper colorea con `~/.local/etc/i-Haklab/{variables,functions}` (`ok`/`msg`/`info`/`warn`/`tip`/`err`, `banner`) y concatena ambos en `~/.local/share/traffic/combined_*.txt`.
  - Flags `--dry-run` (solo `adb shell id`+`cat /proc/net/tcp`), `--once` (`timeout 5`), `--grid` (default Unicode) / `--no-grid` (plain).
- **Variantes sin ADB**: `dumpsys netstats` / `dumpsys connectivity` / `dumpsys network_management` (estadísticas por UID, no conexiones live), VPNService (requiere app). `tcpdump`/`tshark` requieren `CAP_NET_RAW` / root, no viables en `shell`.
