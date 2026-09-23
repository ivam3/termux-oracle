# Freebuff: `!comando` falla con `terminal command broker protocol response was missing`

Escenario real (sept 2026, `freebuff 0.0.184` vía `apt install freebuff` desde `ivam3/termux-packages`): la TUI arranca bien, pero **todo** comando con prefijo `!` retorna `Error: Terminal command broker failed: terminal command broker protocol response was missing`.

## Causa: `process.execPath` es el loader, no el binario

El TUI de freebuff/codebuff ejecuta cada `!cmd` en un **broker aislado**: el padre hace `spawn(process.execPath, ["--terminal-command-broker"])`, le envía 1 request JSON por `stdin` y el hijo reporta el resultado en un fichero one-shot en `os.tmpdir()`. Si el broker no arranca, no hay fichero → `protocol response was missing` (sin fallback a consola).

Bajo el wrapper glibc de Termux el padre corre como `ld-linux … freebuff.real`, así que:

```bash
freebuff --smoke-tree-sitter 2>&1 | grep execPath
# execPath=/data/data/com.termux/files/usr/glibc/lib/ld-linux-aarch64.so.1  ← el LOADER
```

El padre genera `spawn(loader, ["--terminal-command-broker"])` y el loader responde `unrecognized option '--terminal-command-broker'` → el broker nunca nace. Evidencia directa: invocar el binario `.real` sin loader da `cannot execute: required file not found` (INTERP `/lib/ld-linux…` inexistente en Termux).

**`patchelf --set-interpreter` NO es vía**: el ELF parcheado da `Segmentation fault` al ejecutarse directo (Android/SELinux bloquea con `seccomp`). Se debe seguir invocando vía loader.

## Fix aplicado en `ivam3/termux-packages` (`freebuff 0.0.174-2`)

1. **Helper C** (`lib/freebuff_helper.c`): `setenv("FB", "$PREFIX/bin/freebuff", 1)` + `$HOME` dinámico (nunca hardcodear `/data/…/home`).
2. **Parche binario en `postinst`** (idempotente, misma longitud para no romper offsets del binario Bun — el needle aparece 1 sola vez, verificado con `grep -c`):
   ```bash
   # executable:process.execPath,args:  →  executable:process.env.FB  ,args:
   python3 - "$SHARE_DIR/freebuff.real" <<'PYEOF'
   import sys
   p = sys.argv[1]
   data = open(p, 'rb').read()
   needle = b'executable:process.execPath,args:'
   repl = b'executable:process.env.FB  ,args:'
   n, r = data.count(needle), data.count(repl)
   if n == 1 and r == 0:
       open(p, 'wb').write(data.replace(needle, repl))
   elif n == 0 and r == 1:
       pass  # ya aplicado
   else:
       sys.exit(1)
   PYEOF
   ```
   El padre parcheado genera `spawn($FB-wrapper, …)` → wrapper nativo → loader + `.real --terminal-command-broker` → funciona.
3. **Autotest en `postinst`**: simula al padre (spawn del wrapper con `CODEBUFF_TERMINAL_COMMAND_BROKER=1` + fichero de protocolo en `$TMPDIR` con prefijo `freebuff-terminal-command-broker-`); exige `{"ok":true}` o aborta la instalación. Nota: el broker se auto-elimina con `SIGKILL` (exit 137 en el test = esperado).

## Verificación

```bash
freebuff --version  # 0.0.184
# En la TUI:
!echo hola   # debe imprimir hola, sin error de broker
```

## Réplica sin i-HakLab

1. `pkg install glibc clang python` (requiere repo glibc, `arch=aarch64`).
2. Descargar `freebuff-linux-arm64.tar.gz`, extraer a `~/.local/share/freebuff/freebuff.real`.
3. Compilar un helper como el de `references/compilacion-glibc.md` añadiendo el `setenv("FB", …)`.
4. Aplicar el parche Python de arriba al `.real`.
5. Verificar con el autotest del punto 3 (usar `setsid` para aislar el `SIGKILL` de auto-reap).

## Generalización

Cualquier binario Bun/glibc con **self-re-exec** (`process.execPath` para re-lanzarse: brokers, watchdogs, updaters) sufre lo mismo bajo loader-exec. Patrón: exponer la ruta del wrapper nativo por env y parchear el punto de invocación. `/bin/sh` sí existe en Android (`/bin → /system/bin`), así que el shell del broker no es problema.
