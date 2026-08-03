# Wiki Oficial de Termux (Developer's Wiki) 📖

Conocimiento **oficial** del proyecto Termux sobre el **build environment**, desarrollo y mantenimiento de paquetes para Android/Termux. Fuente: [termux/termux-packages.wiki](https://github.com/termux/termux-packages/wiki).

> ⚠️ **IMPORTANTE — Desambiguación de "termux-packages"**
>
> Esta sección documenta los **paquetes oficiales de Termux** (`github.com/termux/termux-packages`): el entorno de compilación (`build.sh`), cómo portar y crear paquetes para el repositorio oficial.
>
> **NO es** el proyecto personal [ivam3/termux-packages](https://github.com/ivam3/termux-packages), que es la fuente de instalación del ecosistema i-HakLab y está documentado en [docs/recursos/termux-packages.md](../recursos/termux-packages.md). Ambos comparten el mismo nombre pero son proyectos distintos.

## Contenido

### Build Environment y Compilación

| Página | Descripción |
|--------|-------------|
| [build-environment.md](./build-environment.md) | Estructura del repositorio `termux-packages` y configuración del entorno de compilación |
| [building-packages.md](./building-packages.md) | Proceso completo de compilación de paquetes con `build-package.sh` |
| [creating-new-package.md](./creating-new-package.md) | Cómo crear un paquete nuevo: `build.sh`, control DEBIAN, termux-create-package |
| [auto-updating-packages.md](./auto-updating-packages.md) | Actualización automática de versiones de paquetes |
| [common-porting-problems.md](./common-porting-problems.md) | Problemas comunes al portar software de Linux a Android/Termux (Bionic, glibc) |

### Sistema y Estructura

| Página | Descripción |
|--------|-------------|
| [termux-execution-environment.md](./termux-execution-environment.md) | Entorno de ejecución de Termux: variables, `$PREFIX`, runtime |
| [termux-file-system-layout.md](./termux-file-system-layout.md) | Layout del filesystem: rutas de Android vs Termux, límites de longitud |
| [termux-and-android-10.md](./termux-and-android-10.md) | Comportamiento de Termux en Android 10+ (scoped storage, permisos) |

### Repositorios y Convenciones

| Página | Descripción |
|--------|-------------|
| [package-management.md](./package-management.md) | Gestión de paquetes: `pkg` vs `apt`, errores de repositorio |
| [how-to-mirror-repos.md](./how-to-mirror-repos.md) | Cómo crear un mirror de los repositorios oficiales de Termux |
| [coding-guideline.md](./coding-guideline.md) | Guía de estilo para contribuir al proyecto Termux |

## Nota

- Contenido en **inglés** (fuente oficial). Se mantiene tal cual de `termux/termux-packages.wiki`.
- Para el repositorio personalizado de i-HakLab, ver [docs/recursos/termux-packages.md](../recursos/termux-packages.md).
