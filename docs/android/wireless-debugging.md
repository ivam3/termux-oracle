# Depuración Inalámbrica (Wireless Debugging) desde Termux 🤖📶

La **Depuración Inalámbrica** te permite conectar Termux a dispositivos Android mediante la red Wi-Fi sin necesidad de utilizar cables USB o adaptadores OTG. Esto es sumamente útil tanto para controlar otros celulares dentro de la misma red local como para realizar **autodepuración** (controlar tu propio dispositivo directamente desde Termux ejecutándose en él).

---

## 🛠️ Requisitos Previos
1. Que los dispositivos estén conectados a la **misma red Wi-Fi**.
2. Haber instalado `android-tools` en Termux (`pkg install android-tools`).
3. Activar las **Opciones de desarrollador** en el dispositivo (ver la guía de [ADB](./adb.md)).

---

## 📱 1. Método Moderno: Android 11 o Superior (Con Código de Emparejamiento)

A partir de Android 11, Google incorporó un protocolo seguro que permite emparejar y conectar dispositivos mediante un código PIN aleatorio de 6 dígitos sin necesidad de cables previos.

### Paso 1: Habilitar la Depuración Inalámbrica
1. Ve a los **Ajustes de Android** > **Opciones de desarrollador**.
2. Desplázate hacia abajo y busca **Depuración inalámbrica**.
3. Activa la opción y concede los permisos necesarios en la red Wi-Fi actual.
4. Presiona sobre el texto **Depuración inalámbrica** para ingresar a su menú de configuración interna.

### Paso 2: Emparejar el Dispositivo (Pairing)
1. En el menú de depuración inalámbrica, selecciona **Vincular dispositivo con código de vinculación** (o "Pair device with pairing code").
2. Aparecerá una ventana emergente que muestra:
   * **Dirección IP y puerto de vinculación** (ejemplo: `192.168.1.15:38421`).
   * **Código de vinculación de Wi-Fi** (ejemplo: `123456`).
3. Abre Termux y ejecuta el comando de emparejamiento usando la IP y el puerto de vinculación de la pantalla:
   ```bash
   adb pair <IP>:<puerto_vinculación>
   # Ejemplo:
   adb pair 192.168.1.15:38421
   ```
4. Termux te solicitará el código: `Enter pairing code:`. Introduce el código de vinculación (ej: `123456`) y presiona Enter.
5. Deberías ver un mensaje de éxito: `Successfully paired to 192.168.1.15:38421`.

### Paso 3: Conectar el Dispositivo (Connect)
1. Una vez emparejado, fíjate en la pantalla principal del menú de "Depuración inalámbrica" (el diálogo de código se habrá cerrado).
2. Verás un apartado llamado **Dirección IP y puerto** (este puerto de conexión **es diferente** al puerto de vinculación del paso anterior; ejemplo: `192.168.1.15:42135`).
3. En Termux, ejecuta el comando de conexión con este nuevo puerto:
   ```bash
   adb connect <IP>:<puerto_conexión>
   # Ejemplo:
   adb connect 192.168.1.15:42135
   ```
4. Verás el mensaje: `connected to 192.168.1.15:42135`. Ya puedes usar `adb shell` u otros comandos.

---

## 📱 2. Método Clásico: Android 10 e Inferior (Requiere Conexión USB Inicial)

En versiones antiguas de Android, no existe el emparejamiento por código de seguridad. Para activar la depuración inalámbrica, se debe indicar temporalmente al servidor del teléfono que escuche en un puerto TCP.

### Paso 1: Configurar el puerto vía USB
1. Conecta el dispositivo a la PC (o a Termux mediante cable OTG).
2. Ejecuta en Termux:
   ```bash
   adb devices
   # Asegúrate de autorizar la ventana emergente en el teléfono objetivo
   ```
3. Indica al dispositivo que configure la conexión TCP en el puerto por defecto `5555`:
   ```bash
   adb tcpip 5555
   ```
4. Desconecta el cable USB.

### Paso 2: Conectar de forma inalámbrica
1. Busca la IP del dispositivo en Ajustes > Información de Wi-Fi (ejemplo: `192.168.1.15`).
2. Conéctate de forma remota:
   ```bash
   adb connect 192.168.1.15:5555
   ```
3. Verás: `connected to 192.168.1.15:5555`.

---

## 🔁 3. Autodepuración: Controlar tu propio celular desde su Termux local

Puedes usar la depuración inalámbrica para controlar el mismo teléfono en el que estás ejecutando Termux. Esto te permite saltar ciertas restricciones del sistema Android (ej. forzar permisos, deshabilitar apps del sistema, usar Shizuku, etc.).

### Flujo de Ejecución (Pantalla Dividida):
1. Inicia Android en **modo de pantalla dividida** o **ventana emergente**: de un lado abre los Ajustes de "Depuración inalámbrica" y del otro abre **Termux** (es necesario porque al cerrar o salir del menú de emparejamiento en Android, los puertos y códigos de vinculación cambian e invalidan la sesión).
2. Sigue los pasos de vinculación utilizando la IP local (`127.0.0.1` o tu IP Wi-Fi local).
3. Ejecuta en Termux local:
   ```bash
   adb pair 127.0.0.1:<puerto_vinculación>
   # Introduce el código de la pantalla dividida
   adb connect 127.0.0.1:<puerto_conexión>
   ```
4. Ya puedes ingresar a la shell del sistema operativo de tu propio móvil ejecutando:
   ```bash
   adb shell
   ```
5. Para cerrar la sesión y liberar los puertos inalámbricos al finalizar, ejecuta:
   ```bash
   adb disconnect
   ```
