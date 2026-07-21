# MariaDB en Termux

Referencia rápida para instalación, errores comunes y solución de permisos.

## Instalación

```bash
pkg install mariadb
```

## Issues comunes

### ERROR: InnoDB: Missing FILE_CHECKPOINT / ib_logfile0 was not found

**Causa:** El archivo de log binario de InnoDB falta o está corrupto.

**Solución:**
```bash
echo " " > $PREFIX/var/lib/mysql/ib_logfile0
```

### ERROR: Permiso denegado al conectar con contraseña

**Causa:** El plugin de autenticación usa `unix_socket` en lugar de `mysql_native_password`.
MariaDB en Termux instala por defecto `unix_socket` como plugin de autenticación para `root`,
lo que significa que solo puedes entrar sin contraseña desde el mismo usuario del sistema.
Al intentar conectar con `-p` (contraseña), el servidor rechaza el acceso.

**Solución paso a paso:**

1. Detén el proceso actual de MariaDB
   ```bash
   pkill mariadbd
   ```

2. Inicia MariaDB en modo seguro (salta verificación de privilegios)
   ```bash
   mariadbd-safe --skip-grant-tables &
   ```
   Espera unos segundos a que termine de cargar.

3. Entra a la consola de MariaDB sin contraseña
   ```bash
   mariadb -u root
   ```

4. Dentro de MariaDB, ejecuta estos comandos para cambiar el plugin y asignar contraseña:
   ```sql
   FLUSH PRIVILEGES;
   ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';
   UPDATE mysql.user SET plugin='mysql_native_password' WHERE User='root';
   FLUSH PRIVILEGES;
   EXIT;
   ```

5. Reinicia MariaDB normalmente
   ```bash
   pkill mariadbd
   mariadbd-safe &
   ```

6. Prueba final
   ```bash
   mariadb -u root -proot -e "SELECT user, host FROM mysql.user;"
   ```

### ERROR 1396 (HY000): Operation CREATE USER failed for 'root'@'localhost'
**Causa:** El usuario ya existe pero el plugin de autenticación no coincide.
**Solución:**
```sql
DROP USER root@localhost;
FLUSH PRIVILEGES;
CREATE USER root@localhost IDENTIFIED BY 'root';
```
