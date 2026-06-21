# Ruta de Aprendizaje Nivel 2: Avanzado (Automatización y Redes) 🎯🌐

El nivel avanzado se enfoca en exprimir al máximo el potencial de Termux y el hardware de tu dispositivo Android. Aprenderás a realizar análisis de redes, exponer servidores locales a internet de forma segura, automatizar tareas interactuando con el hardware del móvil (sensores, cámara, batería) y virtualizar otras distribuciones Linux.

---

## 🗺️ Objetivos de Aprendizaje
Al finalizar este nivel, serás capaz de:
1. Utilizar Termux como una plataforma de diagnóstico de red y pentesting básico.
2. Exponer servicios web que corren en tu celular a la red pública mediante túneles seguros.
3. Automatizar scripts de consola que interactúan con el hardware de tu teléfono mediante la API de Termux.
4. Levantar distribuciones completas de Linux (Ubuntu, Debian, Arch Linux) dentro de Termux usando entornos PRoot.

---

## 🌐 1. Diagnóstico de Redes y Exposición de Servicios

Termux te permite auditar redes y levantar servidores desde tu bolsillo:

### A. Auditoría y Escaneo con `nmap`
`nmap` es la herramienta estándar para el descubrimiento de hosts y escaneo de puertos.
```bash
pkg install nmap -y
# Escanear puertos abiertos y detectar servicios en un objetivo
nmap -sV -F 192.168.1.1
```

### B. Exposición a Internet: Túneles Seguros
Si levantas un servidor web en Termux (por ejemplo con Python o Node.js) y quieres mostrarlo a un cliente o amigo en internet, no puedes hacerlo directamente debido al NAT de la red de datos móviles. Para saltar esta barrera, puedes utilizar túneles.

* **cloudflared** (Túneles de Cloudflare - Recomendado y Gratuito):
  ```bash
  pkg install cloudflared -y
  # Iniciar un servidor web local en el puerto 8080
  python -m http.server 8080 &
  # Crear el túnel público
  cloudflared tunnel --url http://localhost:8080
  ```
  *(El comando te devolverá una URL pública temporal del tipo `https://random-subdomain.trycloudflare.com` accesible desde cualquier parte del mundo).*

---

## 📱 2. Interacción con el Hardware: `termux-api`

Termux puede conectarse directamente con el sistema operativo Android para leer el estado del teléfono, enviar mensajes o controlar periféricos. Esto requiere la app complementaria **Termux:API** instalada en tu dispositivo.

### Instalación en Consola:
```bash
pkg install termux-api -y
```

### Ejemplos de Automatización con Hardware:
* **Consultar el estado de la batería**:
  ```bash
  termux-battery-status
  ```
* **Hacer vibrar el dispositivo (por ejemplo, al terminar una tarea larga)**:
  ```bash
  termux-vibrate -d 1000
  ```
* **Tomar una foto con la cámara trasera de forma silenciosa**:
  ```bash
  termux-camera-photo -c 0 foto.jpg
  ```
* **Mostrar una notificación flotante de Android**:
  ```bash
  termux-notification -t "i-HakLab" -c "Escaneo de red completado exitosamente"
  ```

---

## 📦 3. Virtualización Ligera con `PRoot`

Debido a que Termux utiliza un entorno Linux con rutas no estándar (por ejemplo, `/data/data/com.termux/files/usr/bin` en lugar de `/usr/bin`), algunos scripts de Linux complejos fallan al ejecutarse. La solución es simular un entorno Linux estándar mediante **PRoot** sin necesidad de acceso root.

### Herramienta oficial: `proot-distro`
```bash
pkg install proot-distro -y
```

### Comandos de Administración:
* **Listar distribuciones disponibles**: `proot-distro list`
* **Instalar una distribución (ej. Ubuntu)**: `proot-distro install ubuntu`
* **Ingresar a la consola de la distribución**: `proot-distro login ubuntu`
* **Detener o reiniciar el contenedor**: `proot-distro clear-cache`

Dentro de este entorno virtualizado, podrás ejecutar cualquier herramienta de Debian/Ubuntu clásica instalando paquetes mediante el comando tradicional `apt install` con compatibilidad total de rutas.

---

## 🧪 Práctica de Laboratorio Nivel 2

Para superar este nivel de automatización, realiza el siguiente reto:
1. Instala **Termux:API** en tu celular y el paquete `termux-api` en tu consola.
2. Escribe un script en bash que monitoree el nivel de batería del dispositivo cada 5 minutos.
3. Si el nivel de batería baja del 20%, el script debe:
   * Enviar una vibración larga.
   * Mostrar una notificación flotante en la pantalla con el texto *"¡Batería Baja! Conecta el cargador"*.
4. Pon tu script a correr de forma persistente en segundo plano dentro de una sesión de **Tmux** o configura una tarea programada mediante un bucle de espera de bash.
