# Tool Installation Reference

Mapa de herramientas → método de instalación exacto en Termux.

## Apt nativo (repositorio oficial + ivam3/termux-packages)
```bash
pkg install nmap amass metasploit-framework beef openclaw antigravity-cli
pkg install apktool apksigner dex2jar axmlprinter2 xml2axml
pkg install mariadb postgresql apache2 phpmyadmin
pkg install tor privoxy proxychains-ng
pkg install termux-desktop-xfce termux-docker-qemu udocker
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
```bash
npm install -g @anthropic-ai/claude-code
npm install -g opencode-ai
npm install -g @google/gemini-cli
npm install -g @qwen-code/qwen-code
npm install -g mmx-cli  # minimax-cli
npm install -g @github/copilot
npm install -g @mmmbuto/codex-cli-termux@latest
npm install -g mimocode
npm install -g n8n localtunnel
npm install -g codebuff freebuff  # glibc
npm install -g open-lovable
```

## Gem (Ruby)
```bash
gem install bettercap
gem install aquatone
```

## Wrapper apt (instalación unificada)
Con i-HakLab instalado, usar `apt install <tool>` redirige automáticamente:
| Escribes | Se instala realmente |
|----------|---------------------|
| `apt install sqlmap` | `python3 -m pip install sqlmap` |
| `apt install bettercap` | `gem install bettercap` |
| `apt install claude-code` | `npm install -g @anthropic-ai/claude-code` |
| `apt install nmap` | `pkg install nmap` |

## Adaptación glibc
Herramientas que requieren glibc (no Bionic nativo de Android):
- `claude-code`, `opencode`, `codebuff`, `freebuff`
- `mimocode`, `mistral-vibe`
Se instalan desde ivam3/termux-packages con parche .va39 + loader glibc.

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

## Regla general
1. Si existe como `python-<nombre>` en apt → `pkg install python-<nombre>`
2. Si es herramienta de seguridad popular → buscar en ivam3/termux-packages
3. Si es módulo Python → `pip install` o `apt install <nombre>` (wrapper i-HakLab)
4. Si es módulo Node.js → `npm install -g <nombre>` o `apt install <nombre>` (wrapper i-HakLab)
5. Si es gema Ruby → `gem install <nombre>` o `apt install <nombre>` (wrapper i-HakLab)
6. Si requiere glibc → instalar desde termux-packages
