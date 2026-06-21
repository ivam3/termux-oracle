# Ruta de Aprendizaje Nivel 1: Intermedio (Entorno de Desarrollo) 🎯💻

Una vez que dominas los comandos esenciales de Linux (Nivel 0), el siguiente paso es transformar tu terminal de Termux en un entorno de desarrollo ágil y profesional. Esta ruta te enseñará a configurar editores, instalar lenguajes de programación, gestionar versiones y trabajar de manera remota.

---

## 🗺️ Objetivos de Aprendizaje
Al finalizar este nivel, serás capaz de:
1. Configurar y utilizar un editor de texto en terminal con resaltado de sintaxis y autocompletado.
2. Gestionar múltiples terminales virtuales en tu pantalla usando un multiplexor de consola.
3. Configurar entornos de programación para lenguajes populares como Python, Node.js y C/C++.
4. Automatizar tareas comunes y sincronizar tus proyectos con repositorios remotos en GitHub.

---

## 🛠️ 1. Control de Versiones y Trabajo Remoto

El desarrollo moderno requiere el uso de herramientas de colaboración y acceso remoto:
* **Control de versiones**: Aprende a clonar repositorios y guardar tus cambios. Consulta nuestra [Guía de Git](../termux/git.md).
* **Acceso Remoto**: Trabaja cómodamente desde tu PC conectándote a la terminal del celular. Consulta nuestra [Guía de Servidor SSH](../termux/ssh.md).

---

## ⌨️ 2. Editores de Texto Avanzados en Terminal

Escribir código de forma eficiente requiere un editor adecuado. Olvídate del editor básico por defecto y configura herramientas con resaltado de sintaxis:

### Opción A: Nano Personalizado (Fácil y rápido)
Instala y mejora el comportamiento de `nano`:
```bash
pkg install nano -y
# Habilitar numeración de líneas, soporte de ratón y colores
cat <<EOT > ~/.nanorc
set linenumbers
set mouse
set tabsize 4
include "/data/data/com.termux/files/usr/share/nano/*.nanorc"
EOT
```

### Opción B: Neovim / Vim (Avanzado y altamente extensible)
Para un flujo de trabajo profesional tipo IDE:
```bash
pkg install neovim -y
```
* Aprende a navegar usando atajos de teclado sin ratón (`h`, `j`, `k`, `l` para moverte, `i` para insertar, `Esc` y `:wq` para guardar y salir).
* Puedes instalar configuraciones comunitarias optimizadas para desarrollo móvil (como AstroNvim o NvChad) para añadir autocompletado en tiempo real (*IntelliSense*).

---

## 🖥️ 3. Multiplexor de Terminal: `tmux`

Escribir código en una terminal y tener que cerrarla para ejecutarlo es ineficiente. Con `tmux` puedes dividir tu pantalla en múltiples paneles independientes y pestañas.

### Instalación:
```bash
pkg install tmux -y
```

### Comandos y Atajos Básicos de Tmux:
Todos los atajos en Tmux requieren presionar primero la combinación de teclas de control (`Ctrl + b`), soltarlas y luego presionar la tecla de la acción:

* **Iniciar sesión**: `tmux`
* **Dividir pantalla horizontalmente**: `Ctrl + b` y luego `"`
* **Dividir pantalla verticalmente**: `Ctrl + b` y luego `%`
* **Moverse entre paneles**: `Ctrl + b` y luego la flecha de dirección (`Arriba`, `Abajo`, `Izquierda`, `Derecha`).
* **Cerrar un panel**: Escribe `exit` o presiona `Ctrl + d`.
* **Desacoplar sesión** (dejar procesos corriendo de fondo): `Ctrl + b` y luego `d` (puedes volver a entrar ejecutando `tmux attach`).

---

## 📦 4. Instalación de Entornos de Programación

Prepara los compiladores y entornos de ejecución de los principales lenguajes en Termux:

### A. Entorno Python
Ideal para scripting y seguridad. Consulta la [Guía de Python](../termux/python.md) para detalles sobre pip y entornos virtuales.

### B. Entorno JavaScript / Node.js
Indispensable para desarrollo web y herramientas de automatización modernas:
```bash
pkg install nodejs -y
```
* **Verificar**: `node -v` y `npm -v`.

### C. Entorno C/C++
Necesario para compilar herramientas locales y dependencias:
```bash
pkg install clang make -y
```
* Compila tu primer código en C:
  ```bash
  clang hola.c -o hola
  ./hola
  ```
---

## 🧪 Práctica de Laboratorio Nivel 1

Para superar este nivel, completa el siguiente reto de integración:
1. Conéctate a tu Termux vía **SSH** desde tu PC.
2. Inicia una sesión de **Tmux**.
3. Divide el panel en dos verticalmente: del lado izquierdo abre un script de Python con **Vim** o **Nano**, y del lado derecho deja la terminal libre.
4. Escribe un script simple que haga una consulta HTTP a una API y muestre los datos en formato JSON.
5. Ejecuta tu script en el panel derecho.
6. Súbelo a un repositorio público o privado en tu perfil de **GitHub** usando Git.
