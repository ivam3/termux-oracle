# proroot — Rootless Linux runtime para Android

Reemplazo directo de `proot` sin overhead de ptrace. Ejecuta un userspace Linux glibc completo (Node.js, Python, Git, Chromium) dentro de Android sin root.

## Requisitos

- Android 8.0+ (API 26)
- arm64-v8a (solo aarch64)
- Termux con repositorio ivam3/termux-packages configurado

## Instalación

```bash
pkg install proroot
```

El `postinst` automatiza:

1. Descarga de Ubuntu 24.04 (Noble) rootfs a `$PREFIX/var/lib/proot-distro/containers/proroot/rootfs/`
2. Descarga de los 5 `.so` de proroot a `$PREFIX/lib/proroot/`

### Dependencias

- `wget` — descarga de rootfs y librerías
- `proot-distro` — el rootfs se aloja en el árbol de contenedores de proot-distro

## Uso

### Con auto-detección de rootfs

```bash
proroot /bin/sh -c 'node server.js'
proroot /bin/bash
```

El wrapper detecta automáticamente el rootfs en `containers/proroot/rootfs/` y pasa `-0 --link2symlink -w /`.

### Con `-r` explícito

```bash
proroot -r ~/rootfs-personalizado -0 --link2symlink -w /root /bin/sh
```

### Flags disponibles

| Flag | Descripción |
|------|-------------|
| `-r <rootfs>` | Directorio raíz del guest (obligatorio si no hay auto-detect) |
| `-w <dir>` | Working directory dentro del guest |
| `-b <host>:<guest>` | Bind-mount de ruta host al guest |
| `-0` | Fake uid=0/gid=0 (fakeroot) |
| `--link2symlink` | Emular hardlinks via anchor + symlink groups |
| `--static-loader` / `--no-static-loader` | Forzar exec routing estático |

## Bind-mounts automáticos

El wrapper `proroot` monta automáticamente estas rutas del host dentro del guest:

| Host | Guest | Propósito |
|------|-------|-----------|
| `/data/data/com.termux/files/home` | `/data/data/com.termux/files/home` | Home del usuario de Termux (sin exponer `usr/` bionic) |
| `/sdcard` | `/sdcard` | Almacenamiento externo |
| `/storage` | `/storage` | Almacenamiento compartido |
| *(no bindeado)* | `/tmp` | Usa el `/tmp` del rootfs (más estable que bind). Para compartir temp con Termux: `proroot -b \$TMPDIR:/tmp ...` |

Si la ruta host no existe, el bind se omite silenciosamente (ej: `/sdcard` en algunos dispositivos).

## Estructura de archivos

```
$PREFIX/lib/proroot/
├── libproroot.so              ← Launcher (entrypoint)
├── libproroot-runtime.so      ← Hook (LD_PRELOAD para el guest)
├── libproroot-linker.so       ← Linker glibc (static-pie)
├── libproroot-bridge.so       ← Trampolín de syscalls (static)
└── libproroot-stub-loader.so  ← Static loader para exec routing

$PREFIX/var/lib/proot-distro/containers/proroot/rootfs/
└── ...                         ← Ubuntu 24.04 rootfs
```

El launcher auto-descubre los `.so` compañeros desde `/proc/self/exe` dirname.

## Compatibilidad glibc

| Rootfs | glibc | Funciona |
|--------|-------|----------|
| Ubuntu 24.04 (Noble) | 2.39 | ✅ |
| Ubuntu 26.04 (Resolute) | 2.43 | ❌ (no offset table en proroot v1.2.8) |
| Debian (bookworm) | 2.36 | ✅ (probado upstream) |

Si se necesita otro rootfs, descargarlo manualmente y usar `-r`:

```bash
wget https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-arm64-root.tar.xz
mkdir -p ~/rootfs
tar -xf ubuntu-24.04-*-root.tar.xz -C ~/rootfs
proroot -r ~/rootfs /bin/bash
```

## Comparativa con proot

| Aspecto | proot | proroot |
|---------|-------|---------|
| Mecanismo | ptrace (intercepta syscalls) | LD_PRELOAD + parcheo ELF |
| Overhead por syscall | 2 cambios de contexto | 0 (en-proceso) |
| Rendimiento Node.js | Bajo | Casi nativo |
| Chromium headless | Muy lento | Viable |
| Permisos especiales | No requiere root | No requiere root |
| Arquitecturas | arm, arm64, i686, x86_64 | Solo arm64 |
| Código fuente | Abierto (GPL) | Cerrado (proprietario, binarios gratis) |

## Limitaciones conocidas

- Solo **arm64** (no arm32, i686 ni x86_64)
- Código cerrado (binarios gratuitos, redistribución de binarios modificados no permitida)
- glibc > 2.39 requiere nueva versión de proroot con offset table
- La extracción del rootfs con `tar` puede mostrar errores de hardlink (benignos en Termux)
- No es root real (igual que proot)

## Troubleshooting

| Error | Causa | Solución |
|-------|-------|----------|
| `unable to set CAP_SETFCAP effective capability` | snapd requiere capabilities de Linux no disponibles en rootless | Usar Firefox ESR desde PPA o tarball (ver abajo) |
| `apt install firefox` instala snapd | Ubuntu 24.04 empaqueta Firefox como snap wrapper | Firefox no funciona via snap en ningún runtime rootless (proot ni proroot) |
| `open config file: No such file or directory` | Falta PROROOT_TMP_DIR | Usar `$TMPDIR` de Termux (por defecto) |
| `proroot-ldso: no offset table for glibc X.XX` | glibc no soportada | Usar Ubuntu 24.04 (glibc 2.39) |
| `error while loading shared libraries: libc.so.6` | Linker glibc no encuentra libc | Verificar que el rootfs tenga `/lib/aarch64-linux-gnu/libc.so.6` |
| `chdir workdir failed: /root` | No existe `/root` en rootfs | Usar `-w /` |
| `libproroot.so: Permission denied` | Bit ejecutable faltante | `chmod 755 $PREFIX/lib/proroot/libproroot.so` |

## Firefox en Ubuntu 24.04

Ubuntu 24.04 empaqueta `firefox` como meta-paquete que instala **snapd**. snap requiere `CAP_SETFCAP` y otras capabilities de Linux no disponibles en ningún runtime rootless (proot, proroot). Firefox **no puede ejecutarse via snap** en proroot.

**Workarounds:**
- **Firefox ESR desde PPA mozillateam** (recomendado): `add-apt-repository ppa:mozillateam/ppa && apt install firefox-esr`. ESR es .deb nativo, estable y recibe actualizaciones de seguridad.
- **Firefox release desde tarball**: Descargar el .tar.bz2 oficial de Mozilla a `/opt` y ejecutar directamente. No requiere instalación snap ni apt.
- **chromium-browser**: Alternativa disponible via apt como .deb nativo (no snap).
- **Actualizar a Ubuntu 26.04**: Firefox vuelve a ser .deb nativo, pero **glibc 2.43 rompe compatibilidad con proroot v1.2.8** (no tiene offset table), y **Node.js deja de funcionar**. No se recomienda.

## Integración con i-HakLab

proroot puede usarse para ejecutar herramientas que requieran glibc real en lugar de bionic:

- **Node.js** para frameworks como n8n, code-server, asistentes IA
- **Chromium** headless para Playwright scraping (más rápido que playwright-proot)
- **Metasploit** con gems nativas glibc
- **Python** con wheels C compiladas para glibc

## Enlaces

- Repositorio: https://github.com/coderredlab/proroot
- Paquete termux-packages: `pkg install proroot`
- App proroom (sucesora): en desarrollo por coderredlab
