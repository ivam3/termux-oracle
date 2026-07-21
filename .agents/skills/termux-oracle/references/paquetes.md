# Gestión de Paquetes en Termux

## pkg vs apt
| Comando | Cuándo usarlo |
|---------|---------------|
| `pkg install <paq>` | Instalaciones individuales (auto-refresca repos) |
| `apt install <paq>` | Solo si acabas de hacer `apt update` |
| `apt update && apt upgrade` | Mantenimiento general del sistema |

**Regla de oro:** Usa siempre `pkg install` para herramientas individuales.

## Wrappers i-HakLab (`~/.local/bin/`)
- `apt` → redirige a pip/npm/gem según el paquete, o delega a `$PREFIX/bin/apt`
- `npm` → normaliza alias, ejecuta `pkg2conf` post-instalación

## pkg2conf: Orquestador de post-instalación
| Paquete | Configuración automatizada |
|---------|---------------------------|
| `mariadb` | Arranca con `--skip-grant-tables`, asigna password `root`, habilita `mysql_native_password` |
| `neovim` | Descarga plugins y LSPs |
| `apache2`/`phpmyadmin` | Reemplaza configs default con enlaces a `~/.local/etc/` |
| `tor`/`privoxy` | Vincula configs, enlaza Privoxy a Tor (127.0.0.1:9050) |
| `@google/gemini-cli` | Parchea clipboardy para Android |
| `localtunnel` | Reemplaza openurl.js |
| `mvt` | Parchea base.py y adb_device.py |

## Repositorios adicionales
| Repositorio | Instalación |
|-------------|-------------|
| termux-x11 | `pkg install termux-x11-nightly` |
| tur-repo | `pkg install tur-repo` |
| glibc-repo | `pkg install glibc-repo` |
| root-repo | `pkg install root-repo` |
| x11-repo | `pkg install x11-repo` |

## Paquetes de infraestructura
- `termux-api`, `termux-tools`, `termux-services`, `termux-elf-cleaner`
- `termux-desktop-xfce`, `termux-docker-qemu`, `udocker`
- `termux-am`, `termux-auth`, `termux-keyring`, `termux-exec`

## Python precompilado (evita compilar en Android)
Ver listado completo en `references/python-ecosystem.md`.
