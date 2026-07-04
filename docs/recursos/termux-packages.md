# Termux-Packages: repositorio de herramientas adaptadas para Android 📦

**Termux-Packages** es el repositorio personalizado de **Ivam3** que ofrece más de 120 herramientas y frameworks de ciberseguridad, desarrollo y automatización adaptados (compilados/configurados) para ejecutarse nativamente en **Termux/Android**. Es la fuente principal de instalación del ecosistema **i-HakLab**.

## ¿Qué resuelve?

Muchas herramientas de Linux no están disponibles en los repositorios oficiales de Termux, o los binarios precompilados no son compatibles con ARM64/Bionic. Termux-Packages resuelve esto proporcionando:

- Paquetes `.deb` compilados o configurados específicamente para Android/Termux
- Parches y adaptaciones necesarias para que las herramientas funcionen sin `proot`
- Scripts de post-instalación (`pkg2conf`) que configuran automáticamente cada herramienta
- Integración con los wrappers `apt`/`npm`/`pnpm` de i-HakLab

## Agregar el repositorio a APT

Para añadir termux-packages como fuente de paquetes en Termux, ejecuta:

```bash
# Instalar dependencias
pkg install gnupg

# Crear directorio de fuentes
mkdir -p $PREFIX/etc/apt/sources.list.d

# Descargar la lista de paquetes
curl -s https://raw.githubusercontent.com/ivam3/termux-packages/gh-pages/ivam3-termux-packages.list \
  -o $PREFIX/etc/apt/sources.list.d/ivam3-termux-packages.list

# Descargar e instalar la clave GPG
curl -fsSL "https://raw.githubusercontent.com/ivam3/termux-packages/gh-pages/dists/stable/public_key.gpg" \
  | gpg --dearmor | tee "$PREFIX/etc/apt/trusted.gpg.d/ivam3.gpg" >/dev/null

# Actualizar repositorios
apt update
```

O en un solo comando:

```bash
yes|pkg install gnupg && mkdir -p $PREFIX/etc/apt/sources.list.d && \
curl -s https://raw.githubusercontent.com/ivam3/termux-packages/gh-pages/ivam3-termux-packages.list \
  -o $PREFIX/etc/apt/sources.list.d/ivam3-termux-packages.list && \
curl -fsSL "https://raw.githubusercontent.com/ivam3/termux-packages/gh-pages/dists/stable/public_key.gpg" \
  | gpg --dearmor | tee "$PREFIX/etc/apt/trusted.gpg.d/ivam3.gpg" >/dev/null && \
apt update
```

## Herramientas disponibles

El repositorio incluye más de 120 herramientas. Entre las más destacadas:

| Categoría | Herramientas |
|-----------|-------------|
| **IA y asistentes** | `claude-code`, `opencode`, `gemini-cli`, `qwen-code`, `codex`, `codebuff`, `freebuff`, `minimax-cli`, `mimocode`, `mistral-vibe`, `openclaw`, `antigravity-cli`, `engram`, `opencode` |
| **Pentesting** | `metasploit-framework`, `nmap`, `amass`, `beef`, `bettercap`, `aircrack-ng`, `hydra-gtk`, `hashcat`, `johntheripper` |
| **OSINT** | `sherlock`, `holehe`, `shodan`, `ghunt`, `osintgram`, `theharvester`, `recon-ng`, `maltego` |
| **Android** | `apktool`, `apksigner`, `dex2jar`, `axmlprinter2`, `xml2axml`, `appshark`, `androforensic`, `androbugs`, `scrcpy` |
| **Web** | `sqlmap`, `dirb`, `gobuster`, `wpscan`, `whatweb`, `nikto`, `vulnx`, `wfuzz` |
| **Redes** | `enum4linux`, `enum4linux-ng`, `dnsenum`, `sublist3r`, `amass`, `dns2tcp` |
| **Phishing/SE** | `evilginx2`, `nexphisher`, `lockphish`, `saycheese`, `seeker`, `storm-breaker`, `trape` |
| **Utilidades** | `termux-desktop-xfce`, `termux-docker-qemu`, `udocker`, `code-server`, `ffmpeg`, `bat`, `fzf`, `glow`, `tmux`, `neovim`, `yazi` |

Para la lista completa, consulta el [README del proyecto](https://github.com/ivam3/termux-packages) o la documentación individual en [herramientas/](herramientas/README.md).

## Enlaces

- Repositorio: [github.com/ivam3/termux-packages](https://github.com/ivam3/termux-packages)
- DeepWiki: [deepwiki.com/ivam3/termux-packages](https://deepwiki.com/ivam3/termux-packages)
- Grupo de soporte: [t.me/Ivam3by_Cinderella](https://t.me/Ivam3by_Cinderella)
