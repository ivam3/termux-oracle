# herdr

## ¿Qué es herdr?

**herdr** es una herramienta CLI de reconocimiento y fingerprinting de servidores web, diseñada para identificar tecnologías, cabeceras HTTP, frameworks y metadatos de aplicaciones web de forma rápida. Se distribuye como binario estático compilado para `aarch64-linux` (compatible con Android/Termux sin root ni glibc adicional).

## ¿Para qué es útil la herramienta?

Herdr es útil en fases de reconocimiento pasivo y activo durante auditorías web:

- **Fingerprinting de servidores:** Detecta el servidor web, versión, cabeceras de seguridad y tecnologías expuestas.
- **Análisis de cabeceras HTTP:** Evalúa la presencia y configuración de headers como `X-Frame-Options`, `CSP`, `HSTS`, etc.
- **Reconocimiento rápido:** Binario estático sin dependencias, arranque instantáneo en Android/Termux.
- **Integración en pipelines:** Salida estructurada compatible con scripts y automatizaciones.

## Instalación en Termux (i-HakLab)

```bash
apt install herdr
```

El `postinst` descarga automáticamente el binario estático más reciente desde `https://herdr.dev/latest.json`, verifica el SHA-256 y lo instala en `$PREFIX/bin/herdr`.

## ¿Cómo se usa? (Ejemplos básicos)

**Ejemplo 1: Analizar un dominio**

```bash
herdr https://example.com
```

**Ejemplo 2: Ver versión instalada**

```bash
herdr --version
```

**Ejemplo 3: Ver ayuda**

```bash
herdr --help
```

## Notas de instalación en Termux

- El binario es **estático** (linked con `musl` o equivalente), por lo que funciona directamente con Bionic libc de Android sin adaptaciones adicionales.
- Requiere arquitectura `aarch64`. No compatible con `x86_64` ni `arm`.
- La descarga se realiza desde `https://github.com/herdrdev/herdr/releases/` con verificación de integridad.
- Para compilar manualmente desde fuente en Termux se necesita `rust` + `zig` y el target `aarch64-unknown-linux-gnu`.

## Desinstalación

```bash
apt remove herdr
```

El `prerm` pregunta antes de eliminar los datos de usuario (`~/.config/herdr`, `~/.local/share/herdr`, `~/.cache/herdr`).

## Referencias

- Repositorio upstream: [herdrdev/herdr](https://github.com/herdrdev/herdr)
- Web oficial: [herdr.dev](https://herdr.dev)
- Soporte i-HakLab: [t.me/Ivam3_Bot](https://t.me/Ivam3_Bot)

---
*Esta herramienta es parte del ecosistema i-HakLab para Android/Termux.*
