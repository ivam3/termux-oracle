# termux-oracle skill para agentes de IA

Esta skill proporciona conocimiento experto sobre **Termux** Linux en Android, **i-HakLab** y el repositorio **termux-packages** a agentes de IA como OpenCode, Claude Code, Cline y otros compatibles con el formato SKILL.md.

## Instalación

```bash
# Opción 1: Enlace simbólico
ln -sf $PWD/.agents/skills/termux-oracle ~/.agents/skills/termux-oracle

# Opción 2: Copia directa
cp -r .agents/skills/termux-oracle ~/.agents/skills/termux-oracle

# Opción 3: Usar directamente desde el repo
# (algunos agentes descubren skills desde el directorio del proyecto)
```

## Contenido

| Archivo | Descripción |
|---------|-------------|
| `SKILL.md` | Router principal con detección de entorno, routing por intención y reglas de ejecución |
| `references/termux-setup.md` | Instalación, paquetes, repositorios |
| `references/ihaklab.md` | Comandos i-HakLab, wrappers, archivos clave |
| `references/tool-install.md` | 190+ herramientas con su método de instalación exacto |
| `references/android-limitations.md` | Bionic vs glibc, proot, ADB, limitaciones de Android |
| `references/docker-alternatives.md` | udocker, termux-docker-qemu, proot |
| `references/python-ecosystem.md` | Paquetes Python precompilados, compilación, entornos virtuales |
| `scripts/detect-env.sh` | Script de detección automática del entorno |

## Base de conocimiento

La skill referencia la documentación completa en `docs/` de este repositorio:

- `docs/termux/` — Instalación, paquetes, Python, troubleshooting, glibc
- `docs/android/` — ADB, Fastboot, seguridad, bypass de limitaciones
- `docs/recursos/` — Manual de i-HakLab, 190+ tool docs individuales
- `docs/recursos/herramientas-ihaklab.md` — Manual completo (~970 líneas, 17 secciones)
- `docs/recursos/termux-packages.md` — Repositorio de herramientas adaptadas
