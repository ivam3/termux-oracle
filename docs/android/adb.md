# Introducción a ADB (Android Debug Bridge) desde Termux 🤖🔌

**ADB (Android Debug Bridge)** es una herramienta de línea de comandos versátil que te permite comunicarte y controlar un dispositivo Android de forma directa. Permite realizar acciones de depuración, instalar aplicaciones, transferir archivos, ejecutar comandos en el sistema operativo Android subyacente y acceder al logcat del sistema.

Con Termux, puedes instalar y ejecutar ADB de forma nativa para interactuar con tu propia máquina Android (autodepuración) o controlar otros teléfonos móviles conectados mediante un cable OTG o de forma inalámbrica.

---

## 🛠️ 1. Instalación de ADB en Termux

El paquete oficial que incluye las herramientas de desarrollo de Android (como `adb` y `fastboot`) en Termux se llama `android-tools`.

### Instalación:
```bash
pkg update
pkg install android-tools -y
```

### Verificar instalación:
```bash
adb version
```

---

## ⚙️ 2. Preparación del Dispositivo (Opciones de Desarrollador)

Para poder establecer una conexión ADB con cualquier dispositivo Android, es obligatorio activar la depuración en el sistema.

1. Ve a los **Ajustes de Android** > **Información del teléfono**.
2. Busca el **Número de compilación** y presiónalo **7 veces** seguidas hasta que aparezca un aviso diciendo *"¡Ahora eres desarrollador!"*.
3. Regresa al menú principal de Ajustes y entra en **Sistema** > **Opciones de desarrollador** (u Opciones para desarrolladores).
4. Activa la opción **Depuración por USB**.

---

## 📂 3. Conexión del Dispositivo

### Escenario A: Controlar otro celular vía cable OTG
1. Conecta ambos dispositivos utilizando un cable USB y un adaptador OTG en el teléfono que tiene Termux.
2. Abre Termux y ejecuta:
   ```bash
   adb devices
   ```
3. En el teléfono objetivo, aparecerá una ventana emergente preguntando: *¿Permitir depuración por USB?*. Marca "Permitir siempre" y presiona **Aceptar**.
4. Vuelve a ejecutar `adb devices` en Termux. Deberías ver el identificador del dispositivo junto a la palabra `device`.

### Escenario B: Conectar de forma inalámbrica
* *(Consulta los pasos específicos en la guía detallada de [Depuración Inalámbrica](./wireless-debugging.md) si no cuentas con cables u OTG)*.

---

## 💻 4. Comandos de ADB Esenciales

Una vez establecida la conexión, puedes interactuar con el dispositivo mediante los siguientes comandos:

* **`adb devices`**: Lista todos los dispositivos conectados y autorizados.
* **`adb shell`**: Abre una sesión de consola interactiva en el sistema operativo Android del dispositivo remoto.
  * *Uso*: Si ejecutas `adb shell`, pasarás a interactuar con la shell de Android (`/system/bin/sh`), la cual es diferente de la shell local de Termux.
  * *Para ejecutar un comando directo*: `adb shell pm list packages` (lista las aplicaciones instaladas).
* **`adb push <origen_en_termux> <destino_en_android>`**: Envía un archivo local desde Termux al almacenamiento del dispositivo.
  * *Ejemplo*: `adb push archivo.txt /sdcard/`
* **`adb pull <origen_en_android> <destino_en_termux>`**: Descarga un archivo desde el dispositivo hacia tu carpeta actual en Termux.
  * *Ejemplo*: `adb pull /sdcard/fotos.zip .`
* **`adb install <ruta_apk>`**: Instala un archivo de aplicación `.apk` en el dispositivo objetivo.
* **`adb logcat`**: Muestra en tiempo real los registros detallados de diagnóstico del sistema de Android (depuración de fallos de apps).
* **`adb reboot`**: Reinicia el dispositivo de manera remota.

---

## ⚠️ 5. Solución de Problemas Frecuentes

### Error: "device unauthorized"
* **Causa**: Conectaste el dispositivo pero no has aceptado la ventana de confirmación de huella digital de la clave en su pantalla.
* **Solución**: Desbloquea la pantalla del celular objetivo, acepta la ventana emergente de depuración y vuelve a correr `adb devices`.

### Error: "no devices/emulators found"
* **Causa**: El dispositivo no está conectado correctamente, el cable no soporta transferencia de datos o la depuración USB se desactivó.
* **Solución**: Revisa la conexión física, asegúrate de usar un cable de datos de buena calidad, apaga y enciende de nuevo la opción "Depuración USB" en las opciones de desarrollador.
* **Reiniciar el servidor ADB**:
  ```bash
  adb kill-server
  adb start-server
  ```
