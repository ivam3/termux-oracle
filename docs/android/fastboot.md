# Flasheo y Fastboot desde Termux 🤖⚡

**Fastboot** es una herramienta de diagnóstico y protocolo de comunicación de muy bajo nivel utilizada para modificar el sistema de archivos flash de los dispositivos Android a través de una conexión USB. Permite interactuar directamente con el **Bootloader** (cargador de arranque) del dispositivo antes de que se cargue el sistema operativo Android.

Desde Termux, es posible utilizar Fastboot para desbloquear bootloaders, flashear recuperaciones personalizadas (como TWRP/OrangeFox), instalar ROMs personalizadas o parchear el kernel para obtener permisos de Root (Magisk/KernelSU).

---

## ⚠️ advertencias Importantes (Leer antes de proceder)
* **Pérdida de datos**: Desbloquear el bootloader de un dispositivo borra de forma automática y obligatoria **todos los datos del usuario** (restablecimiento de fábrica).
* **Riesgo de Brick**: Flashear un archivo incorrecto (como un firmware incompatible o una partición equivocada) puede dejar el dispositivo permanentemente inservible ("hard brick"). Procede únicamente si comprendes los riesgos.

---

## 🛠️ 1. Requisitos de Conexión en Termux

A diferencia de ADB, **Fastboot NO funciona de manera inalámbrica**. Debido a que el sistema operativo Android no está cargado cuando el celular está en modo bootloader, las conexiones de red Wi-Fi no existen.

### Conexión Física Requerida:
1. Instala `android-tools` en Termux (`pkg install android-tools`).
2. Conecta el dispositivo que vas a flashear al teléfono que tiene Termux utilizando un **cable USB compatible con transferencia de datos** y un **adaptador OTG** conectado al teléfono de Termux.
3. Asegúrate de que el teléfono de Termux tenga suficiente batería, ya que alimentará al teléfono objetivo durante el proceso.

---

## 🔄 2. Acceder al Modo Bootloader / Fastboot

Existen dos formas de reiniciar tu dispositivo en el modo adecuado para interactuar con Fastboot:

### Método A: Mediante comandos de ADB (Si el celular está encendido)
Con el celular conectado por USB a Termux y con la depuración activa, ejecuta:
```bash
adb reboot bootloader
```

### Método B: Mediante botones físicos (Si el celular está apagado)
1. Apaga por completo el dispositivo.
2. Mantén presionada la combinación de botones correspondiente a tu fabricante (usualmente **Bajar Volumen + Botón de Encendido** o **Subir Volumen + Botón de Encendido**).
3. Suéltalos cuando la pantalla muestre el menú de Fastboot (a menudo representado con la palabra "FASTBOOT" o una mascota de Android siendo reparada).

---

## 💻 3. Comandos de Fastboot Esenciales

Una vez que el dispositivo objetivo se encuentra en modo bootloader y conectado a Termux, ejecuta los siguientes comandos en la terminal:

### A. Verificar Conexión
```bash
fastboot devices
```
* Deberías ver el número de serie de tu dispositivo seguido de la palabra `fastboot`.
* Si no aparece nada, revisa la conexión física OTG y asegúrate de dar permisos de conexión USB en la ventana emergente que Android podría mostrar en el teléfono que ejecuta Termux.

### B. Desbloquear el Bootloader (OEM Unlock)
*(Dependiendo de la marca, el comando puede variar)*:
```bash
# Para la mayoría de dispositivos modernos:
fastboot flashing unlock

# Para dispositivos antiguos:
fastboot oem unlock
```
* **Nota**: Sigue las instrucciones que aparecerán en la pantalla del celular objetivo utilizando los botones de volumen para confirmar el desbloqueo.

### C. Flasheo de Particiones
El flasheo reemplaza el contenido de una partición de memoria por una imagen de sistema (`.img`).

* **Flashear un Recovery personalizado (TWRP/OrangeFox)**:
  ```bash
  fastboot flash recovery recovery.img
  ```
* **Flashear un Boot image parcheado (para Root/Magisk)**:
  ```bash
  fastboot flash boot boot.img
  ```
* **Flashear la partición de super/sistema (ROMs)**:
  ```bash
  fastboot flash system system.img
  ```

### D. Cargar de forma temporal (Boot temporal)
Si deseas arrancar una imagen de recuperación (recovery) sin guardarla permanentemente en el dispositivo, puedes correr:
```bash
fastboot boot recovery.img
```
* El teléfono se reiniciará cargando el recovery temporalmente. Al reiniciar normalmente, conservará su recovery original.

### E. Reiniciar el Dispositivo
Una vez termines las operaciones de flasheo, reinicia el dispositivo al sistema operativo de forma normal:
```bash
fastboot reboot
```
---

## 🛠️ 4. Solución de Problemas Frecuentes en Termux

### Error: "waiting for device"
* **Causa**: Fastboot no detecta el dispositivo conectado.
* **Solución**:
  1. Comprueba que el cable USB esté firmemente conectado.
  2. Verifica que el dispositivo objetivo muestre la pantalla de Fastboot.
  3. Ejecuta `lsusb` en Termux para verificar si Android detecta el dispositivo USB conectado a nivel de hardware.
  4. En algunos dispositivos, es necesario ejecutar fastboot con permisos especiales o reiniciar la sesión USB en Termux.
