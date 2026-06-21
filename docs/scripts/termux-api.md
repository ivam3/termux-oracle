# Interacción con Hardware vía Termux-API 📱🔌

La suite **Termux-API** permite a los scripts de consola de Termux acceder a las capacidades de hardware nativas y las funciones del sistema operativo Android. Mediante esta herramienta, puedes interactuar con sensores, leer el GPS, tomar fotos, enviar mensajes SMS, leer portapapeles y generar diálogos nativos directamente en la pantalla de tu móvil.

---

## 🛠️ 1. Instalación y Requisitos

La arquitectura de Termux-API consta de dos componentes obligatorios:

1. **La Aplicación Android (APK)**:
   * Debe descargarse de la misma tienda de donde instalaste Termux (se recomienda **F-Droid**).
   * **Nombre**: *Termux:API*
   * *Nota: Esta app no tiene interfaz visual (no tiene ícono de inicio); actúa como un servicio de puente de fondo.*
2. **El Cliente de Terminal (Consola)**:
   * Debe instalarse en Termux para proveer los comandos de consola que interactúan con el APK.
   ```bash
   pkg install termux-api -y
   ```

---

## 📂 2. Arsenal de Comandos de Termux-API

A continuación se detallan los comandos más útiles clasificados por su funcionalidad:

### A. Sensores y Ubicación (Telemetría)
* **`termux-location`**: Obtiene la geolocalización actual mediante GPS o red celular. Devuelve datos en formato JSON (latitud, longitud, altitud, precisión).
  * *Uso*: `termux-location -p gps`
* **`termux-battery-status`**: Muestra información del estado de carga, porcentaje, temperatura y salud de la batería.
* **`termux-sensor`**: Lee datos en tiempo real de los sensores del teléfono (acelerómetro, giroscopio, magnetómetro, sensor de luz, etc.).
  * *Uso*: `termux-sensor -l` (lista sensores) y `termux-sensor -n "Light Sensor" -c 1` (lee el sensor de luz una vez).

### B. Control del Hardware y Multimedia
* **`termux-camera-photo`**: Captura una fotografía utilizando la cámara integrada sin necesidad de abrir la aplicación de cámara oficial.
  * *Parámetros*: `-c <ID>` (0 para cámara trasera, 1 para delantera).
  * *Ejemplo*: `termux-camera-photo -c 0 foto_seguridad.jpg`
* **`termux-torch [on|off]`**: Enciende o apaga la linterna del flash de la cámara.
* **`termux-vibrate`**: Hace vibrar el dispositivo. Puedes especificar la duración en milisegundos con `-d <ms>`.
* **`termux-volume`**: Lee o modifica los niveles de volumen del sistema (llamadas, multimedia, alarma, sistema).
* **`termux-brightness [0-255]`**: Ajusta el nivel de brillo de la pantalla.

### C. Elementos de Interfaz de Usuario (Diálogos de Android)
Permiten interactuar de forma visual en la pantalla sin usar la consola:
* **`termux-dialog`**: Despliega cuadros de diálogo nativos en la pantalla de Android (para solicitar texto, números, contraseñas o listas).
  * *Ejemplo (Entrada de texto)*:
    ```bash
    RESPUESTA=$(termux-dialog text -t "¿Cuál es tu objetivo?" | jq -r '.text')
    echo "Objetivo seleccionado: $RESPUESTA"
    ```
* **`termux-toast`**: Muestra un mensaje emergente rápido en la parte inferior de la pantalla (Toast Notification).
  * *Uso*: `termux-toast -c red -b black "Proceso finalizado"`
* **`termux-notification`**: Crea una notificación persistente en la barra superior de Android con botones interactivos y acciones personalizadas.

### D. Telefonía, Mensajería y Portapapeles
* **`termux-clipboard-get`** / **`termux-clipboard-set <texto>`**: Permite leer y escribir en el portapapeles compartido del sistema operativo Android.
* **`termux-sms-list`**: Lista los mensajes SMS recibidos en el dispositivo (devuelve JSON).
* **`termux-sms-send`**: Envía un SMS a un número específico.
  * *Uso*: `termux-sms-send -n +34600000000 "Mensaje automático desde i-HakLab"`

---

## 💻 3. Ejemplo Práctico: Alarma Anti-Intrusión

El siguiente script en Bash utiliza Termux-API para vigilar si el cargador es desconectado del dispositivo (indicando que alguien ha movido el celular), haciendo vibrar el teléfono, encendiendo la linterna y enviando una alerta visual.

```bash
#!/usr/bin/env bash

echo "Activando alarma anti-intrusos..."
termux-toast "Alarma de Seguridad Activada"

# Bucle de monitoreo
while true; do
    # Consultar si el cargador está conectado (devuelve true o false en status)
    ESTADO_CARGA=$(termux-battery-status | jq -r '.status')

    if [ "$ESTADO_CARGA" != "CHARGING" ]; then
        termux-notification -t "¡Alerta de Seguridad!" -c "Cargador desconectado. Movimiento detectado." --sound --vibrate 1000
        # Bucle de sirena visual y vibración
        for i in {1..5}; do
            termux-torch on
            termux-vibrate -d 500
            sleep 0.5
            termux-torch off
            sleep 0.5
        done
        break
    fi
    sleep 3
done
```
*(Nota: Este script requiere tener instalado el paquete `jq` para analizar la salida JSON de `termux-battery-status`).*
