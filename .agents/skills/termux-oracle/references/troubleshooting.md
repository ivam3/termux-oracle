# Solución de Problemas Comunes en Termux

## ERROR: `CANNOT LINK EXECUTABLE`
**Causa:** El linker de Android no resuelve dependencias `.so`.
**Solución:**
```bash
pkg install termux-elf-cleaner
termux-elf-cleaner <ruta_al_binario>
```

## ERROR: `Permission Denied` (acceso a almacenamiento interno)
**Causa:** Android aísla a Termux en su propio sandbox.
**Solución:**
```bash
termux-setup-storage
```
Aceptar la ventana emergente de permisos.

## ERROR de Hard Links (SELinux)
**Causa:** SELinux bloquea `hardlink()`.
**Solución:** Usar copy+delete o `ln -s` (enlaces simbólicos) en lugar de hard links.

## ERROR de Daemons (CodeGraph, etc.)
**Causa:** Android impide fork de daemons tradicionales.
**Solución:**
1. `termux-fix-shebang <archivo>`
2. Forzar ejecución en primer plano o usar `CODEGRAPH_NO_DAEMON=1`

## ERROR: `404 Not Found` al ejecutar `pkg install`
**Causa:** Mirror temporalmente caído.
**Solución:**
```bash
termux-change-repo
```
Seleccionar mirror alternativo (Grimler o Albatross).

## PulseAudio: servidor configurado por usuario
**Causa:** `PULSE_SERVER` definida en `envvariables`.
**Solución:** Eliminar `export PULSE_SERVER=...` de `~/.local/etc/i-Haklab/envvariables`.

## MariaDB: `InnoDB: Missing FILE_CHECKPOINT`
**Solución:**
```bash
echo " " > $PREFIX/var/lib/mysql/ib_logfile0
```

## MariaDB: Permiso denegado al conectar con contraseña
Ver `references/mariadb.md`.

## MariaDB: `ERROR 1396 (HY000): Operation CREATE USER failed`
**Solución:**
```sql
DROP USER root@localhost;
FLUSH PRIVILEGES;
CREATE USER root@localhost IDENTIFIED BY 'root';
```
