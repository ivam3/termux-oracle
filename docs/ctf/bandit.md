# OverTheWire: Bandit - Guía de Inicio desde Termux 🏴‍☠️

**Bandit** es el juego introductorio de la plataforma OverTheWire. Está especialmente diseñado para principiantes absolutos en el entorno de línea de comandos de Linux. Te enseña a moverte por el sistema de archivos, leer archivos ocultos, filtrar texto y utilizar protocolos básicos de comunicación de red.

Resolver Bandit desde Termux es una de las mejores formas de familiarizarse con el entorno móvil de terminal antes de usar suites avanzadas como **i-HakLab**.

---

## 🔑 Conectándose al Nivel 0

Para iniciar el juego, debes conectarte al servidor del juego mediante SSH desde Termux.

### Comando de Conexión:
```bash
ssh bandit0@bandit.labs.overthewire.org -p 2220
```

* **Usuario**: `bandit0`
* **Contraseña**: `bandit0`
* **Puerto**: `2220`

> [!TIP]
> Si te aparece un error que indica que el comando `ssh` no se encuentra, instálalo en Termux ejecutando:
> ```bash
> pkg install openssh
> ```

---

## 🛠️ Conceptos y Comandos Clave por Niveles

A lo largo del juego, necesitarás utilizar diversos comandos de Linux. Aquí tienes una referencia rápida de lo que aprenderás a usar:

### 📁 Navegación e Inspección Básica (Niveles 0 a 5)
* **`ls`**: Lista el contenido de un directorio. Usa `ls -la` para ver archivos ocultos.
* **`cd`**: Cambia de directorio.
* **`cat`**: Muestra el contenido de un archivo en pantalla.
* **`file`**: Identifica el tipo de datos de un archivo (útil cuando el archivo no tiene extensión o su nombre contiene caracteres extraños).
* **`find`**: Busca archivos en el sistema basándose en su tamaño, permisos o propietario.

### 🔍 Filtrado y Búsqueda de Texto (Niveles 6 a 11)
* **`grep`**: Filtra líneas de texto que coinciden con un patrón específico. Esencial para encontrar contraseñas largas en archivos masivos.
* **`sort` y `uniq`**: Ordena líneas de texto y filtra líneas duplicadas (útil para encontrar la única línea que no se repite).
* **`strings`**: Extrae cadenas de texto legibles de archivos binarios ejecutables.
* **`base64`**: Decodifica contraseñas u otros datos que han sido codificados en Base64.
* **`tr`**: Traduce o reemplaza caracteres (útil para descifrar cifrados César como ROT13).

### 🌐 Redes y Transferencia de Datos (Niveles 12 a 15)
* **`ssh`**: Conectarse de forma segura a otros servidores utilizando llaves privadas en lugar de contraseñas.
* **`nc` (netcat)**: Envía y recibe datos a través de conexiones de red TCP o UDP.
* **`openssl s_client`**: Conéctate a puertos que emplean cifrado SSL/TLS.

---

## 💡 Consejos para la Resolución de Retos

1. **Guarda tus contraseñas**: Cada nivel que resuelvas te dará la contraseña para acceder al siguiente usuario (por ejemplo, la contraseña del nivel 1 sirve para el usuario `bandit1`). Apúntalas en un bloc de notas o guárdalas en un archivo en Termux.
2. **Lee la ayuda**: Si te atascas, la página oficial de OverTheWire proporciona una lista de comandos sugeridos para cada nivel. Puedes consultar su sintaxis en internet o directamente en Termux usando `man <comando>`.
3. **Caracteres especiales en nombres de archivos**: Si un archivo se llama `-` o tiene espacios en su nombre, no podrás abrirlo con un simple `cat -`. Usa rutas relativas (ej. `cat ./-`) o comillas (ej. `cat "nombre del archivo"`).
