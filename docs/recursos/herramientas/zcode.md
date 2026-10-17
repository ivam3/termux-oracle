# ZCode (zcode.z.ai)

## ¿Qué es ZCode?

**ZCode** es un harness de vibe coding con IA (modelos GLM-5.3) distribuido como aplicación Electron arm64. A diferencia de los agentes CLI puros, ZCode es una app gráfica: en Termux corre como binario glibc nativo aarch64 sobre `termux-x11`, sin proot.

## ¿Para qué es útil la herramienta?

ZCode convierte Termux en un entorno de desarrollo asistido por IA, permitiendo:

*   **Desarrollo Autónomo:** delegar tareas como "corrige este bug" o "añade tests a este módulo".
*   **Edición Directa de Archivos:** el agente lee archivos, propone ediciones y las aplica tras tu confirmación.
*   **Gestión de Git:** commits, ramas y Pull Requests de forma autónoma.
*   **Investigación de Código:** mapear arquitecturas y dependencias sin intervención manual exhaustiva.

## Instalación

```bash
pkg install zcode
```

Requiere `termux-x11` para la ventana (la ayuda `--help` es estática y funciona sin X).

## ¿Cómo se usa? (Ejemplos básicos)

**Ejemplo 1: Ver la ayuda (sin X)**

```bash
zcode --help
```

**Ejemplo 2: Abrir un proyecto en la GUI**

```bash
termux-x11 :0 &
DISPLAY=:0 zcode ~/proyectos/mi-app
```

**Ejemplo 3: Ver la versión**

```bash
zcode --version
```

## Consideraciones Adicionales

*   **Solo hay artefacto Electron:** no existe CLI separado; el único binario es `ZCode-*-linux-arm64.deb` / `.rpm` / `.AppImage` (`cdn-zcode.z.ai`). `zcode --help` es estático (no lanza Electron).
*   **Sin root:** se inyecta `--no-sandbox` y `--disable-dev-shm-usage` (`/dev/shm` no es escribible sin root); render por software (`--disable-gpu --use-gl=angle --use-angle=swiftshader --in-process-gpu`).
*   **Fuentes y tema:** requiere `fontconfig-glibc`, `freetype-glibc` y `gnome-themes-extra` (tema `Adwaita:dark` por defecto); sin esto el texto es invisible (ventana blanca/negra con cursor `|`).
*   **Seguridad:** ten en cuenta los riesgos de inyección de prompts indirectos al permitir que el agente procese código de fuentes no confiables.

## Proceso de adaptación a Termux (glibc nativo) — replicable

Patrón para cualquier app Electron arm64 sin CLI separado. Resultado en zcode: 83 archivos vendorizados (61 `.so` reales + 22 symlinks) desde 19 `.deb` Debian bookworm arm64.

### Diagnóstico (síntoma → causa → fix)

| Síntoma | Causa | Fix |
|---|---|---|
| `zcode.real: .../glibc/lib/libc.so: invalid ELF header` | `libc.so` en glibc es un **script de texto** `GROUP(libc.so.6...)`, no ELF; libs Bionic (`libnss`, `cups` de `$PREFIX/lib`) declaran `NEEDED [libc.so]` y el loader glibc lo abre como ELF | No mezclar ABIs: `LD_LIBRARY_PATH` y `RUNPATH` solo con libs glibc; vendorizar las Bionic desde Debian |
| `CANNOT LINK ... /usr/glibc/lib/libc.so has bad ELF magic: 2f2a2047` en hijos (`sh`, `update-desktop-database`) | `LD_LIBRARY_PATH` incluía `$PREFIX/glibc/lib` y los hijos Bionic encontraban el script `libc.so` | `LD_LIBRARY_PATH` del wrapper = **solo** `~/.local/share/zcode/lib`; libs glibc vía `RUNPATH` |
| `libicuuc.so.78: undefined symbol: expf, version GLIBCXX_3.4` | `libicu-glibc 78.3` compilado con GCC 16 espera `expf@GLIBCXX_3.4`, pero `expf` vive en `libm` como `GLIBC_2.27` | Vendorizar `libicu76` Debian (usa `GLIBC_2.27`); forzar Debian para `libicu*` aunque exista en glibc |
| `no version information available` + `undefined symbol: udev_device_get_action, version LIBUDEV_183` | `libudev` de glibc sin símbolos `LIBUDEV_183` que pide el binario | Vendorizar `libudev1` Debian; forzar Debian para `libudev*` |
| `Error initializing NSS ... libsqlite3.so.0: cannot open` → `FATAL nss_error=-5925` | `libsqlite3` no existe en glibc | Vendorizar `libsqlite3-0` Debian |
| Ventana negra total | GPU Mali/Adreno + Mesa glibc sin render por software | Flags `--disable-gpu --use-gl=angle --use-angle=swiftshader --in-process-gpu` + `LIBGL_ALWAYS_SOFTWARE=1` |
| Ventana blanca + texto invisible (cursor `\|` sí cambia) | `GTK_THEME` vacío sin tema Adwaita GTK3 (solo temas X11 `Raleigh`) + `fonts.conf` glibc apunta a `$PREFIX/glibc/share/fonts` (inexistente) | `GTK_THEME=Adwaita:dark` + `gnome-themes-extra` + symlink `$PREFIX/share/fonts/*` → `$PREFIX/glibc/share/fonts/` + `FONTCONFIG_PATH=$PREFIX/glibc/etc/fonts` |
| `FATAL: .../platform_shared_memory_region ... /dev/shm` → `SIGTRAP` | `/dev/shm` no escribible sin root | Siempre inyectar `--disable-dev-shm-usage` (+ `--no-sandbox`, sandbox SUID imposible sin root) |

### Tabla de vendoring (26 SONAMEs → 19 debs)

Todos Debian bookworm `arm64` (`https://deb.debian.org/debian/pool/main/...`). Varios SONAMEs comparten deb:

| SONAMEs pedidos | Deb Debian | Motivo (sin variante `-glibc` en Termux) |
|---|---|---|
| `libnspr4.so`, `libplc4.so`, `libplds4.so` | `n/nspr/libnspr4_4.35-1_arm64.deb` | NSPR Bionic pide `libc.so` |
| `libnss3.so`, `libnssutil3.so`, `libsmime3.so` | `n/nss/libnss3_3.87.1-1+deb12u2_arm64.deb` | NSS Bionic pide `libc.so` |
| `libcups.so.2` | `c/cups/libcups2_2.4.2-3+deb12u9_arm64.deb` | CUPS Bionic |
| `libatspi.so.0` | `a/at-spi2-core/libatspi2.0-0_2.46.0-5_arm64.deb` | AT-SPI Bionic |
| `libatk-1.0.so.0` | `a/atk1.0/libatk1.0-0_2.36.0-2_arm64.deb` | ATK Bionic |
| `libatk-bridge-2.0.so.0` | `a/at-spi2-atk/libatk-bridge2.0-0_2.38.0-1_arm64.deb` | ATK-bridge Bionic |
| `libxdamage.so.1` | `libx/libxdamage/libxdamage1_1.1.6-1_arm64.deb` | Sin variante glibc |
| `libgtk-3.so.0`, `libgdk-3.so.0` | `g/gtk+3.0/libgtk-3-0_3.24.38-2~deb12u3_arm64.deb` | GTK Bionic (arrastra `im-*.so`, `libprintbackend-*`) |
| `libavahi-common.so.3` | `a/avahi/libavahi-common3_0.8-10+deb12u1_arm64.deb` | Dep. transitiva de CUPS |
| `libavahi-client.so.3` | `a/avahi/libavahi-client3_0.8-10+deb12u1_arm64.deb` | Dep. transitiva de CUPS |
| `libgssapi_krb5.so.2` | `k/krb5/libgssapi-krb5-2_1.20.1-2+deb12u5_arm64.deb` | Dep. transitiva de CUPS (reutiliza `$PREFIX/glibc/lib` si existe) |
| `libkrb5.so.3` | `k/krb5/libkrb5-3_1.20.1-2+deb12u5_arm64.deb` | Idem |
| `libk5crypto.so.3` | `k/krb5/libk5crypto3_1.20.1-2+deb12u5_arm64.deb` | Idem |
| `libkrb5support.so.0` | `k/krb5/libkrb5support0_1.20.1-2+deb12u5_arm64.deb` | Idem |
| `libgdk_pixbuf-2.0.so.0` | `g/gdk-pixbuf/libgdk-pixbuf-2.0-0_2.42.10+dfsg-1+deb12u4_arm64.deb` | Dep. de GTK (arrastra `libpixbufloader-*`) |
| `libjpeg.so.62` | `libj/libjpeg-turbo/libjpeg62-turbo_2.1.5-2_arm64.deb` | Dep. de `gdk-pixbuf` |
| `libicuuc.so.76`, `libicui18n.so.76`, `libicudata.so.76` | `i/icu/libicu76_76.1-4_arm64.deb` | **Forzar Debian siempre** (bug `expf@GLIBCXX_3.4` en glibc 78.3) |
| `libudev.so.1` | `s/systemd/libudev1_252.39-1~deb12u2_arm64.deb` | **Forzar Debian siempre** (falta `LIBUDEV_183` en glibc) |
| `libsqlite3.so.0` | `s/sqlite3/libsqlite3-0_3.40.1-2+deb12u2_arm64.deb` | No existe en glibc (NSS lo exige) |

Los debs arrastran extras que también se copian (ej. `libfreebl3`, `libnssckbi`, `libsoftokn3`, `libssl3` desde nss; `im-*.so` desde gtk): total **61 `.so` + 22 symlinks = 83 archivos** en `~/.local/share/zcode/lib/`. Verificar con `ls ~/.local/share/zcode/lib | wc -l` y `ldd zcode.real` sin `not found`.

### Procedimiento paso a paso

1.  **Descarga y extracción** (artefacto oficial, no hay CLI separado):
    ```bash
    curl -fsSL -o staging/ZCode.deb "https://cdn-zcode.z.ai/zcode/electron/releases/${VERSION}/linux-arm64/ZCode-${VERSION}-linux-arm64.deb"
    dpkg-deb --fsys-tarfile staging/ZCode.deb | tar -xf - -C staging/squashfs-root
    cp -a staging/squashfs-root/opt/ZCode/. ~/.local/share/zcode/
    mv ~/.local/share/zcode/zcode ~/.local/share/zcode/zcode.real
    ```
2.  **Vendoring** por cada SONAME (función `vendor_extract_deb` en `postinst`):
    ```bash
    rm -rf staging/vendor-extract && mkdir -p staging/vendor-extract
    dpkg-deb --fsys-tarfile "$tmpdeb" | tar -xf - -C staging/vendor-extract
    find staging/vendor-extract \( -type f -o -type l \) -name "*.so*" -exec cp -a {} "$VENDOR_LIB_DIR/" \;
    ```
    Reglas: si el SONAME ya existe en vendor se salta; si existe en `$PREFIX/glibc/lib` se reutiliza **excepto** `libicu*` y `libudev*` (siempre Debian); luego `chmod 755` y crear symlinks SONAME faltantes (`libatk-1.0.so.0 → libatk-1.0.so.0.23609.1`, etc.).
3.  **Parcheo** (`patchelf-glibc`):
    ```bash
    patchelf --set-interpreter $PREFIX/glibc/lib/ld-linux-aarch64.so.1 "$SHARE_DIR/zcode.real"
    patchelf --set-rpath '$ORIGIN:$ORIGIN/lib:$PREFIX/glibc/lib' "$SHARE_DIR/zcode.real"
    # Repetir para chrome_crashpad_handler, chrome-sandbox, libEGL.so, libGLESv2.so, libffmpeg.so
    ln -sf "$SHARE_DIR/icudtl.dat" $PREFIX/glibc/lib/icudtl.dat  # idem v8_context_snapshot.bin, snapshot_blob.bin
    ```
    Verificar: `readelf -l zcode.real | grep INTERP` → loader glibc; `readelf -d zcode.real | grep RUNPATH` → `$ORIGIN:$ORIGIN/lib:...`.
4.  **Fuentes y tema:**
    ```bash
    mkdir -p $PREFIX/glibc/share/fonts
    for f in $PREFIX/share/fonts/*; do ln -sf "$f" $PREFIX/glibc/share/fonts/ 2>/dev/null; done
    # depends: fontconfig-glibc, freetype-glibc, gnome-themes-extra
    ```
5.  **Wrapper C** (`lib/zcode_helper.c`, `clang -O2 -o $PREFIX/bin/zcode`): reglas innegociables —
    * `LD_LIBRARY_PATH` = **solo** vendor dir (jamás `$PREFIX/glibc/lib`; glibc va por `RUNPATH`).
    * `--help`/`--version` estáticos con `printf` (cero Electron, cero X).
    * Sin args o sin `DISPLAY` → tip en `stderr`, nunca lanzar Electron a ciegas (evita `SIGTRAP`/`Missing X`).
    * Con `DISPLAY` → inyectar `--no-sandbox --disable-dev-shm-usage --disable-gpu --use-gl=angle --use-angle=swiftshader --in-process-gpu` si faltan; env `LIBGL_ALWAYS_SOFTWARE=1`, `GDK_BACKEND=x11`, `ELECTRON_OZONE_PLATFORM_HINT=x11`, `FONTCONFIG_PATH=$PREFIX/glibc/etc/fonts`, `GTK_THEME=Adwaita:dark` si vacío; `execv(zcode.real)`.
6.  **Verificación:**
    ```bash
    zcode --help 2>&1 | grep -c "invalid ELF\|has bad ELF"  # 0
    ld-linux-aarch64.so.1 --library-path vendor:glibc --list zcode.real | grep -c "not found"  # 0
    termux-x11 :0 & DISPLAY=:0 zcode /tmp  # ventana oscura con texto visible
    ```

## CLI + API (sin X11): `zcode-cli` y `APIKEY_zcode`

Además de la app gráfica existe el **CLI npm** (`zcode-app-cli`, modelos GLM vía API Zhipu).
No necesita X11 ni Electron: funciona en Termux puro.

### Instalación y convivencia con el wrapper desktop

```bash
npm install -g zcode-app-cli   # i-Haklab lo configura vía pkg2conf (caso zcode-app-cli)
```

* Upstream trae shebang `#!/usr/bin/env node` → se repara con `termux-fix-shebang`.
* El binario npm vive como **`zcode-cli`**; `zcode` queda reservado al wrapper desktop
  (si `npm` crea `$PREFIX/bin/zcode` apuntando al CLI, `pkg2conf` lo renombra a `zcode-cli`).
* Pre-configuración: Android bloquea hardlinks (`EACCES`), y el launcher crea
  `config.json` vía `tmp+link()` — por eso `pkg2conf` pre-siembra
  `~/.zcode/cli/config.json` (modo `600`) desde `config.example.json`.

### API key (`i-Haklab setapikey` → `APIKEY_zcode`)

```bash
i-Haklab setapikey   # plataforma zcode → guarda APIKEY_zcode en ~/.local/etc/i-Haklab/variables
```

### Uso desde Neovim (CodeCompanion, adapter `zcode`)

`~/.config/nvim/lua/plugins/codecompanion.lua` define el adapter `zcode`
(`openai_compatible` contra `https://open.bigmodel.cn/api/paas/v4`, modelo `glm-4.5-air`,
lee `APIKEY_zcode` del entorno). Para usarlo:

```vim
:CodeCompanionChat adapter=zcode
```

o edita `strategies` (`chat`/`inline`/`agent`) en ese archivo. No requiere el binario
`zcode`/`zcode-cli`: habla directo con la API por HTTP (vía `plenary.nvim`, que en Termux
usa `$PREFIX/tmp` gracias al workaround de `TMPDIR`/`XDG_RUNTIME_DIR` en el mismo archivo).

---
*Nota: ZCode integra los modelos GLM en el ecosistema i-Haklab como app gráfica nativa glibc.*
