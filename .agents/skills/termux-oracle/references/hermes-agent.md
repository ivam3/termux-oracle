# Hermes Agent Reference

## ¿Qué es?

Agente de IA personal de código abierto (Nous Research). Multi-plataforma: CLI, TUI, mensajería (Telegram, Discord, Slack, WhatsApp, etc.), escritorio (Electron). Escrito en Python + TypeScript.

## Instalación en Termux

```bash
pkg install hermes
```

El paquete .deb de ivam3/termux-packages ejecuta un postinst que:

1. Clona el repo en `~/.hermes/hermes-agent/`
2. Crea venv Python (stdlib, sin uv)
3. `pip install -e '.[termux-all]' -c constraints-termux.txt`
   - `psutil`, `cryptography` ya están como `python-psutil`, `python-cryptography` del sistema → pip no los compila
   - Fallback: `.[termux]` → `.`
4. `npm install` (browser tools + TUI)
5. Configura `~/.hermes/` (.env, config.yaml, SOUL.md, skills)
6. Shim en `$PREFIX/bin/hermes` → entry point del venv

## Dependencias del sistema

```
python, nodejs-lts, python-pip, python-psutil, python-cryptography,
clang, rust, make, pkg-config, libffi, openssl, ca-certificates, curl,
git, ripgrep, ffmpeg, playwright-proot, termux-api
```

## Diferencias clave Termux vs Linux

| Aspecto | Termux | Linux |
|---------|--------|-------|
| Gestor Python | stdlib venv + pip | uv |
| psutil | python-psutil (pkg) | compilado desde source |
| cryptography | python-cryptography (pkg) | compilado desde source (Rust) |
| Navegador | playwright-proot (proot) | Playwright nativo |
| Node.js | nodejs-lts (pkg) | tarball a ~/.hermes/node/ |
| Desktop | No disponible | Electron |
| Gateway | nohup background | systemd |

## Configuración

- `~/.hermes/config.yaml` — ajustes generales
- `~/.hermes/.env` — API keys (solo secretos)
- `~/.hermes/SOUL.md` — personalidad del agente
- `~/.hermes/hermes-agent/` — código + venv

## Comandos básicos

| Comando | Función |
|---------|---------|
| `hermes` | Iniciar chat interactivo |
| `hermes setup` | Configurar API keys |
| `hermes gateway` | Iniciar pasarela de mensajería |
| `hermes update` | Actualizar código |
| `hermes -p <perfil>` | Usar perfil específico |

## Ciclo de mantenimiento del paquete

- **Versión**: `2026.Y.M.D` (formato fecha del release tag de GitHub)
- **preinst**: elimina `~/.hermes/hermes-agent/` existente
- **postinst**: clona, construye venv, pip install, npm install, configura
- **prerm**: elimina `~/.hermes/hermes-agent/` (conserva `~/.hermes/` con config)
- **postrm**: mensaje de confirmación

## Notas para el agente

- Hermes Agent usa su propio ecosistema de skills compatibles con el estándar abierto. La skill `termux-oracle-skill` puede instalarse como skill de Hermes.
- Playwright en Termux requiere `playwright-proot` (Chromium headless vía proot Ubuntu). Sin este paquete, las herramientas de navegador fallan.
- psutil en Android falla al compilarse desde pip porque `sys.platform == 'android'` es rechazado por setup.py. Por eso se usa `python-psutil` del sistema.
- El paquete no incluye la app de escritorio (Electron no es compatible con Termux).
- `hermes gateway --verbose` muestra logs en tiempo real; útil para depurar conexión con plataformas de mensajería.
