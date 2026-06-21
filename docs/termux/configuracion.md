# Configuración Inicial Avanzada de Termux 🛠️📱

Una vez instalado Termux, es fundamental realizar una configuración base para garantizar la estabilidad del sistema de paquetes, personalizar el entorno visual y optimizar la usabilidad del teclado en dispositivos móviles.

---

## 🔄 1. Actualización del Sistema y Repositorios

El primer paso indispensable es sincronizar los índices de paquetes con los repositorios oficiales y actualizar los binarios base.

Ejecuta el siguiente comando en tu terminal:
```bash
pkg update && pkg upgrade -y
```

> [!WARNING]
> Durante la actualización, el gestor de paquetes de Debian (`dpkg`) podría preguntarte si deseas reemplazar ciertos archivos de configuración (como `sources.list` o configuraciones de la shell). 
> **Se recomienda presionar `N` (o Enter para la opción por defecto) para conservar las configuraciones locales de Termux y evitar fallos.**

---

## 🌐 2. Cambio de Repositorio (Solución a Repositorios Caídos)

En ocasiones, el servidor por defecto de Termux puede experimentar alta latencia o mantenimiento, causando errores del tipo `Repository under maintenance` o bloqueos al descargar paquetes.

Para solucionar esto o acelerar las descargas, puedes cambiar el mirror oficial:
```bash
termux-change-repo
```
* **Instrucciones**:
  1. Se abrirá una interfaz gráfica en terminal (basada en `dialog`).
  2. Selecciona los repositorios que deseas modificar (se recomienda marcar `Main repository`, `Game repository` y `Science repository` pulsando la barra espaciadora).
  3. Presiona Enter (OK).
  4. Selecciona un mirror alternativo. Los más estables y recomendados a nivel mundial son **Grimler** o **Albatross**, aunque puedes elegir el mirror de **A1 Cloud** o espejos de universidades cercanas para mayor velocidad.

---

## ⌨️ 3. Configuración del Teclado y Teclas Especiales (Extra Keys)

Dado que los teclados táctiles de los celulares carecen de teclas físicas esenciales como `Ctrl`, `Alt`, `Tab`, `Esc` o las flechas de dirección, Termux permite habilitar una fila adicional de teclas virtuales en la pantalla.

Esta configuración se almacena en el archivo `~/.termux/termux.properties`.

### Configuración Recomendada de Teclas:
Para establecer una barra de teclas virtuales completa y funcional, edita o crea el archivo ejecutando:
```bash
mkdir -p ~/.termux
cat <<EOT > ~/.termux/termux.properties
extra-keys = [ \\
  ['ESC','/','-','HOME','UP','END','PGUP'], \\
  ['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN'] \\
]
EOT
termux-reload-settings
```

* **Explicación**: El comando `termux-reload-settings` aplica los cambios de forma instantánea sin reiniciar la aplicación. Ahora tendrás dos filas con accesos directos críticos para moverte en editores como `nano` o `vim` y usar el autocompletado con `Tab`.

---

## 🎨 4. Personalización Visual (Temas y Fuentes)

Termux soporta la modificación de fuentes y combinaciones de colores para reducir la fatiga visual.

### Instalación de Termux:Styling
La forma más sencilla de personalizar la interfaz es instalando la extensión oficial **Termux:Styling** (disponible en F-Droid).
1. Haz una pulsación larga en cualquier parte libre de la terminal.
2. Selecciona **More...** y luego **Style**.
3. Elige **Choose color** (temas como *Gruvbox*, *Solarized Dark* o *Dracula*) y **Choose font** (fuentes monoespaciadas populares como *Fira Code* o *JetBrains Mono*).

---

## 🚀 5. Automatización con Alias y Bienvenida

Para agilizar el flujo de trabajo en consola, puedes definir atajos (alias) en tu archivo de configuración de shell (`~/.bashrc`).

### Ejemplo de Configuración `~/.bashrc`:
```bash
# Habilitar colores en ls
alias ls='ls --color=auto'
alias ll='ls -la'

# Accesos rápidos a directorios
alias sd='cd /sdcard'
alias ihak='cd $HOME/i-HakLab'

# Atajo de actualización rápida
alias update='pkg update && pkg upgrade -y'

# Mensaje de bienvenida personalizado
echo -e "\e[1;32m¡Bienvenido a Termux Core - Comunidad Ivam3bycinderella!\e[0m"
```
Una vez editado el archivo, recárgalo con:
```bash
source ~/.bashrc
```
