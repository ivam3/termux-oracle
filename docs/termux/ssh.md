# Configuración de Servidor SSH en Termux 🖥️🔒

Configurar un servidor SSH en Termux te permite controlar la terminal de tu dispositivo Android de forma remota desde una computadora (Windows, Linux o macOS) u otro móvil. Esto resulta sumamente cómodo para programar, administrar archivos y realizar auditorías sin las limitaciones de la pantalla táctil táctil del celular.

---

## 🛠️ 1. Instalación y Configuración Básica

Por defecto, Termux no incluye un servidor SSH activo. Utiliza el paquete OpenSSH para habilitar este servicio.

### Paso 1: Instalar OpenSSH
```bash
pkg update
pkg install openssh -y
```

### Paso 2: Establecer una Contraseña
El servidor SSH de Termux requiere que tu usuario tenga una contraseña configurada para validar las conexiones remotas:
```bash
passwd
```
* Introduce una contraseña segura y confírmala (los caracteres no se mostrarán en pantalla mientras escribes).

### Paso 3: Iniciar el Servidor
```bash
sshd
```

> [!IMPORTANT]
> **En Termux, el servidor SSH corre en el puerto `8022` por defecto** en lugar del puerto estándar `22`. Esto se debe a que Android no permite a aplicaciones sin permisos de root escuchar en puertos inferiores al `1024`.

---

## 📶 2. Conectarse desde otro Dispositivo (PC/Terminal)

Para realizar la conexión remota, ambos dispositivos deben estar conectados a la misma red local (Wi-Fi).

### Paso 1: Obtener la IP de tu celular y el nombre de usuario
Averigua la dirección IP de tu Android ejecutando:
```bash
ifconfig
# O usando:
ip addr show
```
* Busca la sección correspondiente a tu interfaz inalámbrica (usualmente `wlan0`) y anota la dirección IP (por ejemplo: `192.168.1.15`).
* Obtén tu nombre de usuario interno en Termux con:
  ```bash
  whoami
  ```
  *(Por lo general tiene un formato como `u0_a254`)*.

### Paso 2: Ejecutar la conexión desde la PC
Abre una terminal en tu computadora (o PowerShell en Windows) y ejecuta el siguiente comando:
```bash
ssh <usuario>@<IP_del_celular> -p 8022
```
* **Ejemplo**: `ssh u0_a254@192.168.1.15 -p 8022`
* La primera vez que te conectes, la PC te preguntará si confías en la huella digital del servidor. Escribe `yes` y presiona Enter.
* Introduce la contraseña que configuraste en el Paso 2 de la sección anterior. ¡Listo! Ya estarás en la terminal de Termux desde tu ordenador.

---

## 🔑 3. Conexión Segura con Llaves SSH (Recomendado sin Contraseña)

Para evitar introducir la contraseña en cada inicio de sesión y aumentar drásticamente la seguridad, se recomienda utilizar autenticación por clave pública/privada.

### Paso 1: Generar la llave en tu computadora
Si no tienes una llave SSH en tu PC, créala en su terminal:
```bash
ssh-keygen -t rsa -b 4096
```
*(Presiona Enter a todas las preguntas para usar la ruta por defecto y sin contraseña de llave).*

### Paso 2: Transferir la llave pública a Termux
Puedes transferir el contenido de tu archivo público (`id_rsa.pub`) a Termux. El comando más directo es ejecutar desde tu PC:
```bash
ssh-copy-id -p 8022 <usuario>@<IP_del_celular>
```
Si el comando anterior no está disponible en tu sistema operativo, puedes copiar manualmente el texto de tu archivo `~/.ssh/id_rsa.pub` de la PC y pegarlo en el archivo `~/.ssh/authorized_keys` dentro de Termux.

### Paso 3: Conexión automática
Una vez copiada la llave, conéctate simplemente ejecutando:
```bash
ssh <usuario>@<IP_del_celular> -p 8022
```
La terminal se abrirá instantáneamente sin solicitar contraseña.

---

## 🛑 4. Administración del Servidor SSH

* **Iniciar el servidor automáticamente**: Si deseas que el servidor SSH se inicie cada vez que abras Termux, añade la palabra `sshd` en una línea nueva al final de tu archivo `~/.bashrc`.
* **Detener el servidor**: Para apagar el servidor SSH y cerrar todas las conexiones activas, ejecuta:
  ```bash
  pkill sshd
  ```
* **Verificar si está corriendo**: Puedes chequear si el puerto `8022` está a la escucha usando:
  ```bash
  netstat -tuln | grep 8022
  ```
