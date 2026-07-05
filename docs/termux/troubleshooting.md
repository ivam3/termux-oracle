# Solución de Problemas Comunes (Troubleshooting) 🔥

Este documento recopila los errores críticos de ejecución y entorno más recurrentes reportados en la comunidad **Ivam3bycinderella**, detallando su causa técnica exacta y su solución definitiva.

---

## 1. ERROR: `CANNOT LINK EXECUTABLE`
Este error se presenta de forma común al intentar ejecutar binarios recién compilados o herramientas de sistema de terceros.

* **Causa:** El enlazador dinámico de Android (*linker*) no puede resolver las dependencias de librerías compartidas (`.so`). Esto ocurre comúnmente cuando un programa busca librerías en rutas estándar de Linux de escritorio (`/lib`, `/usr/lib`) en lugar de las rutas específicas del prefijo de Termux.
* **Solución Técnica:** Utilizar la herramienta `termux-elf-cleaner` para limpiar el binario y corregir el `termux-exec` o recompilar asegurando que las variables de entorno de compilación apunten al prefijo correcto:
  ```bash
  pkg install termux-elf-cleaner
  termux-elf-cleaner <ruta_al_binario_afectado>
  ```

---

## 2. ERROR: `Permission Denied` (Al acceder al almacenamiento interno)
Ocurre cuando intentas listar (`ls`) o escribir archivos dentro de carpetas como `/sdcard`, `/storage/emulated/0/Download`, etc.

* **Causa:** Android maneja un sistema de permisos estricto por aplicación. Por defecto, Termux se instala de forma aislada dentro de su sandbox privado y carece de acceso al sistema de archivos compartido del dispositivo.
* **Solución:** Conceder explícitamente el permiso mediante la llamada del sistema interna de Termux:
  ```bash
  termux-setup-storage
  ```
  Acepta la ventana emergente flotante del sistema Android que solicitará acceso a los archivos. Esto creará el directorio dinámico `~/storage` vinculando accesos directos simbólicos correctos.

---

## 3. ERROR de Enlaces en Android / Spool de OpenClaw (Restricción de Hard Links)
Un problema avanzado identificado en herramientas de automatización de mensajería o bots (como el spool de Telegram de OpenClaw).

* **Causa:** El sistema de seguridad SELinux de Android bloquea las llamadas del sistema de enlaces duros (`hardlink()`), retornando un fallo de acceso (`EACCES`), incluso si la carpeta tiene permisos generales. Android restringe esto para evitar escaladas de privilegios entre sandbox de aplicaciones.
* **Solución:** Configurar los módulos de spool o colas de archivos para emplear operaciones de **copia y eliminación directa (Copy + Delete)** o enlaces simbólicos blandos (`ln -s`), en lugar de enlaces duros tradicionales.

---

## 4. ERROR de Conexión en Servidores de CodeGraph / Herramientas Basadas en Daemons
Fallo común al levantar servidores en segundo plano dentro de Termux.

* **Causa:** Muchos binarios asumen la estructura tradicional de Linux y ejecutan un *shebang* inicial apuntando a `#!/bin/bash`. En Termux, Bash se localiza en `/data/data/com.termux/files/usr/bin/bash`. Además, las políticas de Android impiden a las apps de usuario hacer *fork* de daemons tradicionales en ciertas particiones.
* **Solución:** 
  1. Corregir el shebang con `termux-fix-shebang <archivo>`.
  2. Forzar la ejecución en primer plano o desactivar el modo daemon mediante variables de entorno específicas si la herramienta lo soporta (por ejemplo, seteando flags como `CODEGRAPH_NO_DAEMON=1` si aplica).

---

## 5. ERROR: `404 Not Found` al ejecutar `pkg install`
* **Causa:** El servidor espejo (mirror) local al que apunta Termux está temporalmente caído o bajo mantenimiento.
* **Solución:** Cambiar el mirror global de distribución ejecutando:
  ```bash
  termux-change-repo
  ```
  Selecciona la opción principal (Main Repository) y elige una fuente alternativa estable (como los mirrors de *Cloudflare* o *Grimler*).

---

## 6. PulseAudio: `User-configured server at unix:/.../default.pa, refusing to start/autospawn`
* **Causa:** La variable `PULSE_SERVER` está definida estáticamente en `~/.local/etc/i-Haklab/envvariables`. Al estar definida, PulseAudio cree que ya existe un servidor externo y se niega a iniciar el suyo propio.
* **Solución:** Eliminar la línea `export PULSE_SERVER=...` de `~/.local/etc/i-Haklab/envvariables`. PulseAudio en Termux autogestiona su socket en `$TMPDIR/`.

---

## 7. MariaDB: `InnoDB: Missing FILE_CHECKPOINT` / `ib_logfile0 was not found`
* **Causa:** El archivo de log binario de InnoDB falta o está corrupto.
* **Solución:**
  ```bash
  echo " " > $PREFIX/var/lib/mysql/ib_logfile0
  ```

---

## 8. MariaDB: `ERROR 1396 (HY000): Operation CREATE USER failed for 'root'@'localhost'`
* **Causa:** El usuario ya existe pero el plugin de autenticación no coincide.
* **Solución:**
  ```sql
  DROP USER root@localhost;
  FLUSH PRIVILEGES;
  CREATE USER root@localhost IDENTIFIED BY 'root';
  ```

---

## 9. MariaDB: Permiso denegado al conectar con contraseña
* **Causa:** El plugin de autenticación usa `unix_socket` en lugar de `mysql_native_password`.
* **Solución:**
  1. `pkill mariadbd`
  2. `mariadbd-safe --skip-grant-tables &`
  3. `mariadb -u root` (entra sin contraseña)
  4. ```sql
     FLUSH PRIVILEGES;
     ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';
     UPDATE mysql.user SET plugin='mysql_native_password' WHERE User='root';
     FLUSH PRIVILEGES;
     EXIT;
     ```
  5. `pkill mariadbd` y reinicia normalmente
