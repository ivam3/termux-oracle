# terminus-game

## ¿Qué es terminus-game?

**`terminus-game`** es un juego de aventura de texto para aprender a usar la
línea de comandos de Linux. La historia transcurre en un mundo de fantasía
(bosques, academias de magia, cuevas y ciudades) donde los hechizos son
comandos reales de Unix/Linux: `ls`, `cd`, `less`, `pwd`, `cp`, `mv`, `rm`,
`grep`, `touch` y `sudo`.

Es un port nativo para Termux del juego original **Terminus** de Michele
Pratusevich. Reproduce la lógica y el texto original con Node.js (inglés por
defecto, opción de jugar en español) y sustituye el terminal del navegador por
una interfaz de línea de comandos, con soporte opcional de imágenes.

## ¿Para qué es útil?

* **Aprender comandos jugando:** cada comando aparece en un contexto narrativo
  y se practica hasta interiorizarlo.
* **Practicar la terminal:** rutas, navegación entre directorios, lectura de
  archivos, búsqueda de texto y manipulación de objetos.
* **Sin conocimientos previos:** un anciano explica cada comando con
  `man COMANDO`.
* **Progreso persistente:** guarda la partida automáticamente.
* **Uso educativo:** ideal para quien empieza con Linux, talleres o repaso.

## Instalación

El paquete está en el repositorio **ivam3/termux-packages**:

```bash
pkg install terminus-game
terminus-game --version
```

Requiere `nodejs-lts`. Opcionales: `chafa` (imágenes en terminal),
`termux-api` (`termux-open`) e `i-haklab`.

## ¿Cómo se usa?

**Iniciar el juego:**

```bash
terminus-game
```

Primeros pasos dentro del juego:

```text
ls
cd WesternForest
less Sign
pwd
man ls
```

**Opciones útiles:**

```bash
terminus-game --reset          # comenzar una partida nueva
terminus-game --no-save        # jugar sin guardar
terminus-game --save archivo   # usar un archivo de guardado propio
terminus-game --images=chafa   # mostrar imágenes en la terminal
terminus-game --images=open    # abrir imágenes con termux-open
terminus-game --images=off     # desactivar imágenes
terminus-game --script archivo # ejecutar comandos desde un archivo
terminus-game --esp            # jugar en español
terminus-game --lang es        # igual que --esp
terminus-game --help
```

**Jugar en español:**

```bash
terminus-game --esp
```

También se puede dejar configurado para la sesión:

```bash
export TERMINUS_LANG=es
terminus-game
```

Los nombres de salas y objetos, los comandos y los libros del acertijo de
`grep` se mantienen en inglés; las descripciones, diálogos y mensajes se
muestran en español. La partida guardada es compatible entre ambos idiomas.

**Imágenes (opcional):**

```bash
pkg install chafa
terminus-game --images=auto
```

Sin `chafa` el juego funciona igual, solo que sin dibujos.

## Partida guardada y eliminación

```bash
cat ~/.local/share/terminus-game/save.json
```

Puedes cambiar la ruta con `--save` o la variable `TERMINUS_SAVE`. El archivo
sobrevive a actualizaciones, reinstalaciones y a la desinstalación del paquete.

```bash
pkg remove terminus-game
```

El guardado se conserva; bórralo manualmente (o usa `--reset`) para empezar de
cero.

## Consideraciones adicionales

* **Idiomas:** inglés por defecto; `--esp` o `--lang es` para español.
* **Dependencia:** `nodejs-lts` (proporciona `node`).
* **Imágenes opcionales:** `chafa` para dibujos en terminal o `termux-api` para
  abrirlos en una app externa.
* **Compatibilidad:** arquitectura `all`; no usa proot, glibc ni servicios
  externos.
* **Créditos:** juego original de Michele Pratusevich, GPL-2.0
  (<https://github.com/mprat/Terminus>).

---
*Nota: Herramienta integrada en el ecosistema i-Haklab y publicada en ivam3/termux-packages.*
