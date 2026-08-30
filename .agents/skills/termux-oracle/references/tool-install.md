# Tool Installation Reference

Mapa de herramientas → método de instalación exacto en Termux.

## Apt nativo (repositorio oficial + ivam3/termux-packages)
```bash
pkg install nmap amass metasploit-framework beef openclaw antigravity-cli
pkg install apktool apksigner dex2jar axmlprinter2 xml2axml
pkg install mariadb postgresql apache2 phpmyadmin omniroute  # mariadb: ver references/mariadb.md — omniroute: ver docs/termux/omniroute.md
pkg install tor privoxy proxychains-ng
pkg install termux-desktop-xfce termux-docker-qemu udocker proroot
pkg install code-server neovim tmux yazi
pkg install android-tools  # ADB + Fastboot
```

## Pip (Python)
```bash
python3 -m pip install sqlmap shodan bloodhound wfuzz mvt holehe sherlock
python3 -m pip install hashid frida h8mail objection octosuite
python3 -m pip install osrframework phoneintel scrapy snscrape
python3 -m pip install speedtest-cli orbitaldump phomber
```

## Paquetes Python precompilados (vía apt)
Para evitar compilar en ARM, usa versiones precompiladas:
```bash
pkg install python-numpy python-pandas python-scipy python-pillow
pkg install python-cryptography python-lxml python-bcrypt python-brotli
pkg install python-torch python-torchvision python-torchaudio python-onnxruntime
pkg install python-opencv-python python-pyqtwebengine python-tkinter
```
Ver lista completa en `docs/termux/paquetes.md` sección 6.

## Npm (Node.js global)
Algunos agentes tienen versión glibc nativa (recomendada) en ivam3/termux-packages:

| Agente | Nativo glibc (recomendado) | Via npm (alternativa) |
|--------|---------------------------|----------------------|
| opencode | `apt install opencode` (sin Node.js) | `npm install -g opencode-ai` |
| claude-code | `apt install claude-code` | `npm install -g @anthropic-ai/claude-code` |
| codebuff | `apt install codebuff` | `npm install -g codebuff` |
| freebuff | `apt install freebuff` | `npm install -g freebuff` |
| mimocode | `apt install mimocode` | `npm install -g mimocode` |

Agentes solo vía npm:
```bash
npm install -g @google/gemini-cli
npm install -g @qwen-code/qwen-code
npm install -g mmx-cli  # minimax-cli
npm install -g @github/copilot
npm install -g @mmmbuto/codex-cli-termux@latest
npm install -g n8n localtunnel
npm install -g open-lovable
```

## Gem (Ruby)
```bash
gem install bettercap
gem install aquatone
```

## Wrapper apt (instalación unificada) — validar antes de asumir
**Validación**: `bash ~/.agents/skills/termux-oracle/scripts/detect-env.sh | jq .wrapper_apt` y `jq .ihaklab_installed`. Si `true`, el wrapper `~/.local/bin/apt` existe y redirige; si `false`, **no asumir**, usar el comando subyacente directamente.

**Con i-HakLab** (`wrapper_apt=true`): `apt install <tool>` redirige automáticamente:
| Escribes | Se instala realmente | Subyacente sin i-HakLab |
|----------|---------------------|-------------------------|
| `apt install sqlmap` | `python3 -m pip install sqlmap` | `pip install sqlmap` |
| `apt install bettercap` | `gem install bettercap` | `gem install bettercap` |
| `apt install claude-code` | `npm install -g @anthropic-ai/claude-code` | `npm install -g @anthropic-ai/claude-code` |
| `apt install nmap` | `pkg install nmap` | `pkg install nmap` |
| `apt install -h` | muestra `help` de i-HakLab | `pkg install -h` o `apt --help` |

**Sin i-HakLab** (replicable por cualquier agente): usar directamente `pkg install <nativo>` / `pip install <pkg>` / `npm install -g <pkg>` / `gem install <pkg>` sin esperar redirección. Para post-configuración (`pkg2conf`), replicar manualmente: ver `references/ihaklab.md#pkg2conf`.

## Adaptación glibc (Nativo vs Alternativas)
Herramientas que requieren glibc (no Bionic nativo de Android). Tienen dos caminos de instalación:

| Método | Cómo funciona | Rendimiento | Dependencias |
|--------|-------------|-------------|--------------|
| **Nativo glibc** (recomendado) | Binario real + loader `ld-linux-aarch64.so.1` + wrapper C | Máximo | `glibc`, `clang` |
| **vía npm/pip** | Runtime Node.js/Python interpreta el agente | Medio | `nodejs`/`python` |

Agentes con soporte nativo glibc en ivam3/termux-packages:
- `claude-code`, `opencode`, `codebuff`, `freebuff`
- `mimocode`, `antigravity-cli`, `mistral-vibe`

Se instalan con `apt install <agente>` desde ivam3/termux-packages. El postinst descarga el binario, lo renombra `.va39` y compila el helper C que apunta a `$PREFIX/glibc/lib/ld-linux-aarch64.so.1`.

## termux-packages (repositorio Ivam3)
Para instalar desde el repositorio personalizado, agregar fuente primero:
```bash
yes|pkg install gnupg && mkdir -p $PREFIX/etc/apt/sources.list.d && \
curl -s https://raw.githubusercontent.com/ivam3/termux-packages/gh-pages/ivam3-termux-packages.list \
  -o $PREFIX/etc/apt/sources.list.d/ivam3-termux-packages.list && \
curl -fsSL "https://raw.githubusercontent.com/ivam3/termux-packages/gh-pages/dists/stable/public_key.gpg" \
  | gpg --dearmor | tee "$PREFIX/etc/apt/trusted.gpg.d/ivam3.gpg" >/dev/null && \
apt update
```
Más de 120 herramientas disponibles.

## Regla general (validar `detect-env.sh` primero)
1. Validar `detect-env.sh` → `arch`, `glibc_repo`, `wrapper_apt`.
2. Si existe como `python-<nombre>` en apt (`pkg search python-<nombre>`) → `pkg install python-<nombre>` (evita compilar).
3. Si es herramienta de seguridad popular y `glibc_repo=true` → buscar en `ivam3/termux-packages` (`apt update && apt search <tool>` tras añadir repo).
4. Si es módulo Python y `wrapper_apt=false` → `pip install <nombre>` (o `python -m pip install`); si `wrapper_apt=true` → `apt install <nombre>` también funciona pero es wrapper.
5. Si es módulo Node.js y `wrapper_apt=false` → `npm install -g <nombre>`; si `true` → `apt install <nombre>` redirige.
6. Si es gema Ruby → `gem install <nombre>` (wrapper solo si `wrapper_apt=true`).
7. Si requiere glibc y `arch=aarch64` y `glibc_repo=true` → `apt install <agente>` (nativo, ver `Adaptación glibc` abajo); si no, usar vía `npm`/`pip`.
