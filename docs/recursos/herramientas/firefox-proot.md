# Firefox en Ubuntu proot-distro (sin snap)

## ¿Qué es?

**Firefox real dentro de Ubuntu `proot-distro`** en Termux, instalado desde el **repositorio APT oficial de Mozilla** (`https://packages.mozilla.org/apt`). Es un Firefox `.deb` nativo `arm64` (`/usr/lib/firefox/firefox`, ELF aarch64), con actualizaciones vía `apt upgrade`.

No debe confundirse con:
- `pkg install firefox` en Termux nativo (repo `x11`, binario Bionic para Termux-X11, ej. `155.0.1`).
- `apt install firefox` desde `archive.ubuntu.com` dentro del proot (stub transicional a snap, **no funciona**).

Verificado el 2026-09-05 en: Ubuntu `26.04.1 LTS resolute` proot, Termux `aarch64` Android 12, Firefox `155.0.1~build1`.

## ¿Por qué falla el método normal?

Desde Ubuntu 22.04 el paquete `firefox` de `archive.ubuntu.com` es transicional:

```text
firefox 1:1snap1-0ubuntu8 — "Installs Firefox snap and provides some system integration"
```

`/usr/bin/firefox` es un script sh (~2.3 KB) que exige `/snap/bin/firefox`:

```sh
if ! [ -x /snap/bin/firefox ]; then
    echo "Command '$0' requires the firefox snap to be installed." >&2
    echo "snap install firefox" >&2
    exit 1
fi
```

En `proot-distro` snap es imposible:
- `snap version` → `snapd unavailable`.
- `systemctl status snapd` → `System has not been booted with systemd`.
- Sin `systemd`, AppArmor, squashfs ni socket `snapd`, `snap install firefox` siempre da error de conexión. No es problema de red.

Lo mismo aplica a `chromium-browser 2:1snap1-0ubuntu4` (también stub a snap).

## ¿Para qué es útil?

- Navegador completo dentro del proot Ubuntu (perfil, extensiones y certificados separados del Firefox nativo de Termux).
- Desarrollo/testing web con user-agent y rutas Linux estándar (`/usr/bin/firefox`, `/usr/lib/firefox/`).
- Alternativa cuando se necesita el entorno glibc de Ubuntu en vez del Bionic de Termux.
- Headless para screenshots (`--headless --screenshot`) sin X11.

## Instalación (método recomendado: repo Mozilla APT)

Ejecutar **dentro del proot** (`proot-distro login ubuntu -- ...`). No depende de i-HakLab: el wrapper `~/.local/bin/apt` no existe dentro del proot, `apt` resuelve a `/usr/bin/apt` (el `PATH` del proot pone `/usr/bin` antes que `/data/data/com.termux/files/usr/bin`).

```bash
# 1. Eliminar el stub transicional (y restos snap inútiles en proot)
proot-distro login ubuntu -- bash -c 'apt remove -y firefox; apt autoremove -y'

# 2. Prerrequisitos + keyring oficial Mozilla
proot-distro login ubuntu -- bash -c 'apt update && apt install -y wget gnupg && install -d -m 0755 /etc/apt/keyrings && wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O /etc/apt/keyrings/packages.mozilla.org.asc'

# 3. Source + pinning (clave: bloquear el stub de Ubuntu)
proot-distro login ubuntu -- bash -c 'cat > /etc/apt/sources.list.d/mozilla.sources <<EOF
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc
EOF
cat > /etc/apt/preferences.d/mozilla <<EOF
Package: firefox*
Pin: origin packages.mozilla.org
Pin-Priority: 1000

Package: firefox*
Pin: release o=Ubuntu
Pin-Priority: -1
EOF
apt update'

# 4. Instalar (ojo: el l10n NO se llama firefox-l10n-es a secas)
proot-distro login ubuntu -- bash -c 'apt install -y firefox firefox-l10n-es-es firefox-l10n-es-mx'
# Variantes: firefox-l10n-es-ar, firefox-l10n-es-cl. Ver con:
# proot-distro login ubuntu -- apt-cache search "^firefox-l10n-es" | head
```

## ¿Cómo se usa?

### Gráfico (Termux-X11)

Requiere la app **Termux-X11** abierta y el servidor corriendo en Termux (`DISPLAY=:0`). El socket X vive en `$PREFIX/tmp/.X11-unix/X0` (NO en `/tmp/.X11-unix`), y es visible desde el proot en la misma ruta.

```bash
# Desde Termux (host): verificar X activo
ls $PREFIX/tmp/.X11-unix/   # debe mostrar X0
pgrep -a -f "termux-x11"    # debe mostrar com.termux.x11 :0

# Lanzar Firefox del proot
proot-distro login ubuntu -- env DISPLAY=:0 PULSE_SERVER=127.0.0.1 firefox --no-remote
```

Audio: exportar `PULSE_SERVER=127.0.0.1` (o `tcp:127.0.0.1:4713`). Ver `references/termux-x11.md#audio` si el sink queda en `auto_null`.

### Headless (sin X11, verificado)

```bash
proot-distro login ubuntu -- bash -c 'timeout 25 /usr/bin/firefox --headless --no-remote --screenshot /tmp/test-firefox.png about:blank && ls -l /tmp/test-firefox.png'
# OK verificado: PNG ~5-6 KB. Aviso benigno: "Sandbox: Couldn't list /dev".
```

### Verificación post-instalación

```bash
proot-distro login ubuntu -- bash -c 'apt-cache policy firefox | head -n 12'
# Esperado: Installed: 155.0.1~build1, Candidate: 155.0.1~build1 (500 https://packages.mozilla.org/apt, Pin 1000)
# El stub 1:1snap1-0ubuntu8 debe salir con Pin -1.

proot-distro login ubuntu -- bash -c '/usr/bin/firefox --version; file /usr/lib/firefox/firefox-bin; ldd /usr/lib/firefox/firefox-bin | grep "not found" || echo "LDD OK"'
# Esperado: Mozilla Firefox 155.0.1 / ELF 64-bit LSB ARM aarch64 / LDD OK
```

## Consideraciones adicionales

- **Pinning obligatorio.** Sin `/etc/apt/preferences.d/mozilla` un `apt upgrade` puede reinstalar el stub `1:1snap1`. Verificar siempre con `apt-cache policy firefox`.
- **Nombres de idioma.** `apt install firefox firefox-l10n-es` falla (`Unable to locate package`). Usar `firefox-l10n-es-es` y/o `firefox-l10n-es-mx` (también `es-ar`, `es-cl`).
- **Sandbox en proot.** El warning `Sandbox: Couldn't list /dev` es benigno (headless genera el PNG igual). Solo como diagnóstico, no definitivo: `MOZ_DISABLE_CONTENT_SANDBOX=1 firefox --headless ...`.
- **PATH dentro del proot.** `echo $PATH` muestra `/usr/bin` antes que `/data/data/com.termux/files/usr/bin`, así que tras instalar, `/usr/bin/firefox` (Mozilla) tiene precedencia sobre el Firefox nativo de Termux. Antes de instalar, `which firefox` apunta al nativo — no confundir.
- **Alternativa tarball (fallback).** Si `packages.mozilla.org` aún no listara tu `VERSION_CODENAME` (ej. `resolute` el día 1 de un release), descargar el tarball oficial `arm64` a `/opt/firefox` y symlink en `/usr/local/bin/firefox`. Mismo resultado sin tocar `sources.list`.
- **Chromium.** No intentar `apt install chromium-browser` en el proot: es el mismo caso (stub snap). Para Chromium headless en Termux ver `playwright-proot.md` (proroot) en vez de proot-distro.
- **Espacio.** `firefox + 2 l10n` ≈ 78 MB descarga / ~297 MB instalado.

---
*Nota: procedimiento verificado el 2026-09-05. Firefox nativo Termux (`pkg install firefox`, repo `x11`) queda como fallback y no se toca.*
