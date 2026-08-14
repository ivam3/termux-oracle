# Muse Code (Meta) — Agente IA de codificación para Termux

## ¿Qué es Muse Code?

**Muse Code** es el agente de inteligencia artificial de **Meta** para la terminal. Permite generar, modificar y depurar código mediante comandos en lenguaje natural, de forma nativa desde la consola. En el ecosistema i-HakLab se distribuye como el paquete `.deb` de Termux `muse-code`, con soporte para ejecutarse bajo `proot` (sortea el aislamiento de datos de las apps de Android).

- **Origen**: [developer.meta.com/ai/products/muse-code](https://developer.meta.com/ai/products/muse-code)
- **Distribución**: paquete `.deb` de i-HakLab (`apt install muse-code`), arch `aarch64`
- **Dependencias**: `proot`, `curl`, `coreutils`, `python` · **Sugerido**: `i-haklab`
- **Binario**: ELF estático musl Rust aarch64 — corre **nativo** sobre el kernel Android (no requiere root)

## ¿Para qué es útil?

*   **Edición de código asistida**: generar, refactorizar y explicar código en lenguaje natural.
*   **Ejecución de comandos**: `muse-code exec` lanza tareas puntuales sin sesión interactiva.
*   **Autenticación con Meta**: `muse-code login` usa OAuth *device flow* (sirve un código para aprobar en el móvil).
*   **Auto-actualización**: el launcher se actualiza solo a la versión más reciente de Muse en cada ejecución.

## ¿Cómo funciona? (Arquitectura en Termux)

1.  **`postinst` descarga el launcher** desde `https://api.meta.ai/muse-launcher.sh` (verificado por checksum `x-content-sha256`) y lo instala en `~/.local/share/muse-code/muse-launcher`.
2.  **Descarga del binario**: `MUSE_LAUNCHER_INSTALL=1 bash muse-launcher` consulta el *channel manifest* `muse-stable` (`https://api.meta.ai/muse-code/channels/muse-stable`) y descarga el binario más reciente a `~/.local/share/muse-code/muse-bin-<version>`.
3.  **Wrapper `muse-code`** (en `$PREFIX/bin`, con alias `muse`): ejecuta el launcher bajo `proot` para resolver el aislamiento de datos de Android.
4.  **Auto-update en uso**: en cada ejecución `main()` comprueba `.muse-update-checked-at`; si pasaron 3600s (`MUSE_UPDATE_INTERVAL_SECONDS`), se auto-actualizan launcher + binario **en segundo plano** (fork + `>/dev/null 2>&1 &`).

## El problema: aislamiento de datos de Android

El binario musl intenta `readdir("/")`, lo que Android bloquea para apps no-root (`EACCES` sobre el directorio raíz del app-data). La solución sin root es **`proot`**, que enmascara el sistema de archivos:

```bash
proot -r "$PREFIX" \
  -b /data:/data -b /system -b /vendor -b /product -b /system/bin \
  -b /system/lib64 -b /system/etc/hostname -b /system/etc/passwd \
  -b /data/data/com.termux/files -b /sdcard -b /storage -b /mnt \
  -b /proc -b /dev -b /sys -b "$DATA_DIR:$DATA_DIR" \
  /usr/bin/muse-code-bin
```

**Claves del wrapper `muse-code`:**

*   Solo enlaza directorios **existentes** (se recorren con un `for`) para evitar fallos en dispositivos sin `/system`/`/vendor`/etc.
*   **DNS**: `proot -r "$PREFIX"` resuelve `/etc/resolv.conf` → `$PREFIX/etc/resolv.conf` (Termux lo mantiene actualizado).
*   **Zona horaria**: exporta `TZ` desde `getprop persist.sys.timezone`.
*   **Nunca enlazar `/linkerconfig`** (SELinux lo deniega con "sanitize"); en su lugar `postinst` copia el `/linkerconfig/ld.config.txt` del dispositivo a `$PREFIX/linkerconfig/`.
*   `postinst` también instala datos de timezone (`tzdata` vía `pip`) y `localtime` bajo `$PREFIX/share/zoneinfo`.

## Instalación en Termux

```bash
apt install muse-code
# o
pkg install muse-code
```

El paquete instala:
*   `$PREFIX/bin/muse-code` (wrapper proot) + alias `$PREFIX/bin/muse` (symlink)
*   Launcher + binario en `~/.local/share/muse-code/`
*   `fixer` en `$PREFIX/bin` (diagnóstico de posibles problemas)
*   `linkerconfig` + datos de timezone bajo `$PREFIX`
*   Configura el PATH en el rc de tu shell si `~/.local/bin` no está (ver abajo)

## Configuración del PATH según la shell

El `postinst` comprueba el valor de `$PATH` y lo configura automáticamente en el rc correspondiente a la shell activa (`$SHELL`), siguiendo la convención de i-HakLab:

| Shell | Archivo rc | Línea añadida |
|---|---|---|
| fish | `~/.config/fish/config.fish` | `set -gx PATH "$HOME/.local/bin" $PATH` |
| bash | `~/.bashrc` | `export PATH="$HOME/.local/bin:$PATH"` |
| zsh | `~/.zshrc` | `export PATH="$HOME/.local/bin:$PATH"` |
| otra | `~/.profile` | `export PATH="$HOME/.local/bin:$PATH"` |

*   Si `~/.local/bin` **ya está** en `$PATH` (p. ej. porque i-HakLab lo antepone), no añade nada.
*   Es **idempotente**: usa un `grep` previo para no duplicar la línea en reinstalaciones.
*   Tras la instalación: reinicia la shell o haz `source <tu-rc>` para aplicar el cambio.

## Actualizaciones

*   **Cada instalación** (`postinst`) descarga la **versión más reciente** del launcher y binario de los servidores de Meta. El número `0.1.0~R708.1` en `dpkg -l` es solo metadatos del empaquetado, no la versión real de Muse.
*   **En uso normal**, el launcher se auto-actualiza en segundo plano cada hora.
*   **Forzar comprobación inmediata**: `MUSE_SYNC_UPDATE=1 muse-code` o borra `~/.local/share/muse-code/.muse-update-checked-at`.
*   **Desactivar auto-update**: `MUSE_NO_AUTO_UPDATE=1 muse-code`.

## Estado de la validación

- ✅ Instalación limpia vía `dpkg -i` (rebuild del `.deb` con `termux-create-package`).
- ✅ `muse-code --version` → `Muse Code 0.1.0 (0.1.0-R708.1)`.
- ✅ `muse-code exec --provider echo` ejecuta sin errores bajo proot.
- ✅ `muse login` (OAuth device flow) y `muse exec` validados.
- ✅ PATH por shell validado para fish, bash, zsh (idempotente) y escenario i-HakLab presente.
- ⏳ La auto-actualización a futuras versiones de Muse depende de los canales públicos de Meta.

## Consideraciones adicionales

*   Requiere conexión a Internet para descargar launcher/binario y para auto-actualizarse.
*   Los `preinst`/`prerm` se niegan a operar como root (`id -u`), coherente con la política de paquetes de Termux/i-HakLab.
*   La desinstalación (`prerm`) elimina `~/.local/share/muse-code` y el alias `$PREFIX/bin/muse`.
*   **Build del paquete**: `termux-create-package` debe ejecutarse **desde el directorio del paquete** con `termux-create-package manifiest.json` (pasando `--files-dir`/`--deb-dir` provoca un `UnboundLocalError` del propio tool).
*   En i-HakLab está registrada como herramienta `muse-code` (categoría **Agent AI**) con su Readme en `Tools/Readme/`.

---
*Nota: herramienta del ecosistema de agentes AI de Meta, empaquetada para i-HakLab como paquete `.deb` de Termux con wrapper `proot` y auto-actualización gestionada por su launcher.*
