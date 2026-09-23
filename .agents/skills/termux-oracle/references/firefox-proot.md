# Firefox real en Ubuntu proot-distro (sin snap)

En Ubuntu proot ≥22.04 `apt install firefox` instala el stub `1:1snap1-0ubuntu8` (script que exige `/snap/bin/firefox`). `snapd` es `unavailable` sin `systemd` → `snap install firefox` siempre falla por conexión. Instalar desde el **repo Mozilla APT**. Ver doc completa en `docs/recursos/herramientas/firefox-proot.md`.

## Diagnóstico (solo lectura, antes de tocar)

```bash
bash ~/.agents/skills/termux-oracle/scripts/detect-env.sh  # arch=aarch64 esperado
proot-distro list
proot-distro login ubuntu -- bash -c 'cat /etc/os-release | grep -E "VERSION|CODENAME"; dpkg -l | grep -i firefox; cat /usr/bin/firefox 2>/dev/null | head -n 12; snap version 2>&1 | head -n 5'
# Stub confirmado si: ii firefox 1:1snap1-* + /usr/bin/firefox es sh con "requires the firefox snap"
```

## Instalación (copiar-pegar)

```bash
# 1. Quitar stub
proot-distro login ubuntu -- bash -c 'apt remove -y firefox; apt autoremove -y; ls -l /usr/bin/firefox* 2>&1 || echo "stub fuera"'
# Nota: `which firefox` seguirá mostrando /data/.../usr/bin/firefox (nativo Termux, PATH tail) — es normal.

# 2. Keyring Mozilla
proot-distro login ubuntu -- bash -c 'apt update && apt install -y wget gnupg && install -d -m 0755 /etc/apt/keyrings && wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O /etc/apt/keyrings/packages.mozilla.org.asc'

# 3. Source + pinning anti-stub
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
apt update && apt-cache policy firefox'
# Esperado: Candidate 155.0.1~build1 (mozilla, 1000); stub 1:1snap1 con -1.

# 4. Instalar (el l10n NO es firefox-l10n-es)
proot-distro login ubuntu -- bash -c 'apt install -y firefox firefox-l10n-es-es firefox-l10n-es-mx'
```

## Verificación

```bash
proot-distro login ubuntu -- bash -c '/usr/bin/firefox --version; file /usr/lib/firefox/firefox-bin | cut -c1-120; ldd /usr/lib/firefox/firefox-bin 2>&1 | grep "not found" || echo "LDD OK"'
# → Mozilla Firefox 155.0.1 / ELF 64-bit LSB ARM aarch64 / LDD OK

proot-distro login ubuntu -- bash -c 'timeout 25 /usr/bin/firefox --headless --no-remote --screenshot /tmp/test-firefox.png about:blank 2>&1 | head -n 5; ls -l /tmp/test-firefox.png'
# → PNG generado. "Sandbox: Couldn't list /dev" = benigno en proot.
```

## Uso gráfico

```bash
ls $PREFIX/tmp/.X11-unix/  # X0 debe existir (NO /tmp/.X11-unix); app Termux-X11 abierta, DISPLAY=:0
proot-distro login ubuntu -- env DISPLAY=:0 PULSE_SERVER=127.0.0.1 firefox --no-remote
# Audio: PULSE_SERVER=tcp:127.0.0.1:4713 si hace falta. Sink auto_null → ver references/termux-x11.md#audio.
```

## Troubleshooting

| Problema | Causa / Solución |
|----------|------------------|
| `requires the firefox snap` | Stub aún instalado → paso 1 + verificar `ls -l /usr/bin/firefox` sea symlink a `../lib/firefox/firefox` |
| `Unable to locate package firefox-l10n-es` | Nombre wrong → usar `firefox-l10n-es-es` / `-es-mx` (`apt-cache search "^firefox-l10n-es"`) |
| `apt-cache policy` muestra candidato `1:1snap1` | Falta pinning → re-crear `/etc/apt/preferences.d/mozilla` y `apt update` |
| `snap install firefox` error conexión | Esperado en proot (sin systemd). No insistir, usar este runbook |
| `chromium-browser` pide snap también | Mismo caso (`2:1snap1`). Para Chromium headless usar `playwright-proot` (proroot), no proot-distro |
| Duda nativo vs proot | `pkg install firefox` (Termux x11) = fallback válido si solo se quiere navegar; proot solo si se necesita entorno Ubuntu |

## Sin i-HakLab

Replicable tal cual: dentro del proot no existe el wrapper `~/.local/bin/apt`, `apt` es `/usr/bin/apt` real. No usar `pkg` dentro del proot. El `PATH` del proot (`/usr/bin` antes que `/data/.../usr/bin`) da precedencia al Firefox Mozilla tras instalar.
