# Termux Setup Reference

## Instalación de Termux
- **NO** usar Google Play Store (obsoleto)
- **Recomendado:** GitHub Actions → `termux/termux-app` → rama `build` → Artifacts → `app-arm64-v8a-debug.apk`
- **Alternativa:** F-Droid
- **CRÍTICO:** NO mezclar fuentes (todas las apps desde GitHub o todas desde F-Droid)

## Plugins de Termux (misma fuente que la app principal)
| Plugin | Repositorio | Package apt |
|--------|-------------|-------------|
| Termux:API | termux/termux-api | `termux-api` |
| Termux:X11 | termux/termux-x11 | `termux-x11-nightly` |
| Termux:Float | termux/termux-float | — |
| Termux:Styling | termux/termux-styling | — |

## Comandos iniciales
```bash
pkg update && pkg upgrade
termux-setup-storage
pkg install tur-repo x11-repo termux-x11-nightly glibc-repo root-repo
pkg update
```

## Repositorios adicionales
| Repositorio | Instalación |
|-------------|-------------|
| termux-x11 | `pkg install termux-x11-nightly` |
| tur-repo | `pkg install tur-repo` |
| glibc-repo | `pkg install glibc-repo` |
| root-repo | `pkg install root-repo` |
| x11-repo | `pkg install x11-repo` |
| ivam3/termux-packages | Ver `docs/recursos/termux-packages.md` |

## Gestión de paquetes
- `pkg install <paquete>` → recomendado para instalaciones individuales (auto-refresca repos)
- `apt install <paquete>` → más control, requiere `apt update` manual primero
- `apt update && apt upgrade` → mantenimiento general del sistema
- **Siempre preferir `pkg` sobre `apt` para instalaciones individuales**

## i-HakLab Wrappers (si está instalado)
- `~/.local/bin/apt` → wrapper que redirige a pip/npm/gem según el paquete
- `~/.local/bin/npm` → wrapper con normalización de alias y automatizaciones
- `~/.local/bin/pnpm` → wrapper similar para pnpm

## Paquetes de infraestructura
Ver tabla completa en `docs/termux/paquetes.md` (sección 5):
- `termux-am`, `termux-api`, `termux-tools`, `termux-services`, `termux-elf-cleaner`
- `termux-desktop-xfce`, `termux-docker-qemu`, `udocker`
- `fixer`, `termux-exec`, `termux-auth`, etc.
