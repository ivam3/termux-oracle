# OverTheWire: Leviathan - Guía de Ingeniería Inversa y Privilegios 🏴‍☠️

**Leviathan** es un reto CTF de nivel intermedio de la plataforma OverTheWire. A diferencia de Bandit, que se centra en el uso de la terminal de Linux, Leviathan se enfoca en la **ingeniería inversa básica** y la **explotación de privilegios** en programas compilados en C/C++.

Te enseñará a analizar cómo funcionan los programas binarios por dentro, cómo interactúan con el sistema operativo y cómo explotar fallos de diseño lógico.

---

## 🔑 Conectándose al Nivel 0

Para iniciar el juego, conéctate mediante SSH desde tu terminal:

### Comando de Conexión:
```bash
ssh leviathan0@leviathan.labs.overthewire.org -p 2223
```

* **Usuario**: `leviathan0`
* **Contraseña**: `leviathan0`
* **Puerto**: `2223`

---

## 🛠️ Herramientas y Técnicas Clave para Leviathan

Para superar los niveles de Leviathan, necesitarás familiarizarte con las siguientes herramientas y conceptos:

### 1. El bit SUID (Set Owner User ID)
En Linux, algunos archivos ejecutables tienen permisos especiales llamados SUID. Cuando ejecutas un archivo con el bit SUID activo, el programa se ejecuta con los privilegios del **propietario** del archivo en lugar de los tuyos.
* **Propósito en Leviathan**: Encontrarás binarios propiedad de `leviathanX+1` que puedes ejecutar siendo `leviathanX`. Si logras explotar el binario para que ejecute una shell (`/bin/sh`), obtendrás acceso directo como el siguiente usuario.
* **Cómo identificarlo**: Ejecuta `ls -la`. Si en los permisos ves una `s` en lugar de una `x` (ej: `-r-sr-x---`), el archivo tiene el bit SUID activo.

### 2. Análisis Dinámico con `ltrace`
`ltrace` es una herramienta que intercepta y registra las llamadas a funciones de bibliotecas dinámicas ejecutadas por el programa.
* **Caso de uso**: Si un binario SUID te pide una contraseña secreta, puedes ejecutarlo con `ltrace`. Con frecuencia verás cómo el programa compara tu entrada de texto con la contraseña real en texto claro utilizando funciones como `strcmp`.
* **Uso**: `ltrace ./nombre_del_ejecutable`

### 3. Monitoreo de Llamadas al Sistema con `strace`
`strace` intercepta y registra las llamadas al sistema (system calls) realizadas por el programa, como abrir archivos (`open`), leerlos (`read`) o escribir en ellos (`write`).
* **Caso de uso**: Te ayuda a ver si el programa intenta abrir un archivo que no existe en una ruta específica. Podrías crear un enlace simbólico en esa ruta para redirigir el programa a leer la contraseña del siguiente nivel.
* **Uso**: `strace ./nombre_del_ejecutable`

### 4. Enlaces Simbólicos (`ln -s`)
Un enlace simbólico es un tipo especial de archivo que apunta a otro archivo o directorio (como un acceso directo).
* **Concepto clave**: Si un programa SUID intenta abrir un archivo temporal sobre el cual tienes permisos de escritura, puedes crear un enlace simbólico que apunte al archivo de la contraseña del nivel (`/etc/leviathan_pass/leviathanX`), haciendo que el programa lea la contraseña confidencial por ti.
* **Uso**: `ln -s /ruta/archivo/objetivo /ruta/enlace/simbolico`

---

## 💡 Consejos para la Resolución

* **Analiza los strings**: Ejecuta `strings <ejecutable>` antes de descompilar o trazar. A veces hay pistas en texto claro dentro del binario.
* **Comprende el flujo lógico**: A diferencia de Bandit, aquí no se trata de buscar contraseñas ocultas en archivos ocultos del sistema, sino de encontrar fallos en el código compilado (como desbordamientos de búfer simples o fallos lógicos en la verificación de accesos a archivos).
