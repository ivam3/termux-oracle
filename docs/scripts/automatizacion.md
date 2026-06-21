# Proyectos de Automatización en Termux ⚙️🤖

Termux es ideal para ejecutar flujos de trabajo automatizados en segundo plano. Puedes configurar tu dispositivo móvil para que realice copias de seguridad a medianoche, sincronice repositorios de código automáticamente, controle servidores locales o ejecute acciones automatizadas en el momento exacto en que se enciende el teléfono.

Esta guía presenta las tres metodologías principales para automatizar tareas en Termux: **Termux:Boot** (arranque del sistema), **Cronie** (tareas basadas en tiempo) y **Termux-Services** (servicios persistentes).

---

## 🚀 1. Ejecutar Scripts al Encender el Celular (Termux:Boot)

**Termux:Boot** es una extensión oficial de Termux que permite ejecutar código de forma automática inmediatamente después de que el dispositivo Android termina de arrancar, **sin necesidad de abrir la aplicación manualmente**.

### Pasos de Configuración:
1. Instala la aplicación **Termux:Boot** en tu dispositivo Android (disponible en F-Droid).
2. Abre la aplicación Termux:Boot una vez desde la pantalla de inicio para registrar el receptor de arranque en el sistema.
3. En la consola de Termux, crea el directorio reservado para los scripts de arranque:
   ```bash
   mkdir -p ~/.termux/boot
   ```
4. Crea tus scripts dentro de esa carpeta. **Cualquier script ejecutable guardado aquí correrá en segundo plano al reiniciar el celular.**
5. Otorga los permisos de ejecución al script:
   ```bash
   chmod +x ~/.termux/boot/mi_script_arranque.sh
   ```

### Ejemplo de Script de Arranque (`~/.termux/boot/arranque.sh`):
```bash
#!/usr/bin/env bash
# Iniciar el servidor SSH
sshd
# Iniciar una base de datos local (ej. MariaDB o PostgreSQL) si es necesario
# pg_ctl -D $PREFIX/var/lib/postgresql/data start
```

---

## ⏰ 2. Tareas Programadas con Cron (`cronie`)

Para ejecutar scripts en horas específicas del día, intervalos de minutos o días de la semana, Termux soporta el daemon clásico `cron` mediante el paquete `cronie`.

### Instalación:
```bash
pkg install cronie -y
```

### Configurar tareas en el Crontab:
Para abrir el editor del crontab de tu usuario, ejecuta:
```bash
crontab -e
```
*(Nota: Si no has configurado un editor por defecto, se abrirá con `vi`. Puedes presionar `i` para insertar texto, y al terminar presionar `Esc` seguido de `:wq` para guardar).*

### Formato de Reglas Cron (5 campos):
```text
* * * * *  comando_a_ejecutar
│ │ │ │ │
│ │ │ │ └─ Día de la semana (0 - 6) (Domingo = 0 o 7)
│ │ │ └─ Mes (1 - 12)
│ │ └─ Día del mes (1 - 31)
│ └─ Hora (0 - 23)
└─ Minuto (0 - 59)
```

### Ejemplos útiles de Crontab:
* **Ejecutar un script de respaldo cada hora**:
  ```text
  0 * * * * /data/data/com.termux/files/home/backup.sh
  ```
* **Ejecutar una tarea de limpieza todos los domingos a las 3:00 AM**:
  ```text
  0 3 * * 0 pkg clean && apt clean
  ```

> [!IMPORTANT]
> Para que las tareas de Cron se ejecuten, el servicio debe estar corriendo. Puedes iniciarlo manualmente ejecutando `crond` o automatizarlo mediante Termux-Services.

---

## ⚙️ 3. Gestión de Servicios Persistentes (`termux-services`)

Si estás corriendo un servidor web, una base de datos o un bot de Telegram que debe estar activo las 24 horas del día de manera persistente, la mejor opción es usar **termux-services**. Este sistema utiliza `runit` como gestor de servicios para iniciar, detener y reiniciar de forma segura tus demonios en segundo plano.

### Instalación:
```bash
pkg install termux-services -y
```
*(Es necesario reiniciar Termux tras la instalación para que cargue las variables de entorno de runit).*

### Comandos de Administración:
* **Habilitar e iniciar un servicio** (ej. SSH):
  ```bash
  sv-enable sshd
  ```
* **Deshabilitar un servicio**:
  ```bash
  sv-disable sshd
  ```
* **Iniciar un servicio temporalmente** (sin habilitarlo para el arranque):
  ```bash
  sv start sshd
  ```
* **Detener un servicio**:
  ```bash
  sv stop sshd
  ```
* **Verificar el estado de todos los servicios**:
  ```bash
  sv status
  ```

---

## 📁 4. Ejemplo Práctico: Backup Automatizado a Tarjeta SD

El siguiente script comprime tu carpeta de desarrollo y la guarda en la memoria interna de Android, registrando un log de control de errores.

```bash
#!/usr/bin/env bash

# Rutas
ORIGEN="/data/data/com.termux/files/home/proyectos"
DESTINO="/data/data/com.termux/files/home/storage/shared/Backups"
FECHA=$(date +"%Y-%m-%d_%H%M")
LOG_FILE="/data/data/com.termux/files/home/backup_log.txt"

# Crear directorio de destino si no existe
mkdir -p "$DESTINO"

echo "[ $FECHA ] Iniciando copia de seguridad..." >> "$LOG_FILE"

# Comprimir
tar -czf "$DESTINO/backup_proyectos_$FECHA.tar.gz" "$ORIGEN" 2>> "$LOG_FILE"

if [ $? -eq 0 ]; then
    echo "[ $FECHA ] Respaldo completado con ÉXITO." >> "$LOG_FILE"
    termux-toast "Backup de Proyectos completado con éxito."
else
    echo "[ $FECHA ] FALLO en la copia de seguridad." >> "$LOG_FILE"
    termux-notification -t "Error de Backup" -c "Ha ocurrido un error al respaldar tus proyectos."
fi
```
Puedes guardar este script como `~/backup.sh`, otorgarle permisos de ejecución (`chmod +x ~/backup.sh`) y programarlo en tu **Crontab** para que se ejecute todas las noches a las 11:30 PM:
```text
30 23 * * * /data/data/com.termux/files/home/backup.sh
```
