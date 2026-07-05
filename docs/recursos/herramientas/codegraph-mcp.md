# CodeGraph MCP en Termux

## Error común: daemon no arranca

```
/bin/bash: bad interpreter: No such file or directory
```

En `.codegraph/daemon.log`:
```
Failed to start server: EACCES: permission denied, link '.../daemon.pid.X.tmp' -> '.../daemon.pid'
```

### Causas

1. **Shebang incorrecto**: el binario `codegraph` usa `#!/bin/bash`, pero en Termux bash está en `$PREFIX/bin/bash`
2. **Hardlinks bloqueados**: Android/SELinux bloquea la syscall `link()`, que el daemon usa para crear su PID atómicamente

### Solución

#### 1. Corregir shebang
```bash
termux-fix-shebang $(which codegraph)
```

#### 2. Desactivar modo daemon
El daemon falla siempre en Android. CodeGraph tiene un fallback a modo directo (in-process) pero agrega ~6s de reintento. Aceléralo con:

```bash
export CODEGRAPH_NO_DAEMON=1
```

En `opencode.jsonc`:
```jsonc
{
  "mcp": {
    "codegraph": {
      "type": "local",
      "command": ["codegraph", "serve", "--mcp"],
      "env": {
        "CODEGRAPH_NO_DAEMON": "1"
      },
      "enabled": true
    }
  }
}
```

### Verificación
```bash
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}' | codegraph serve --mcp
```
Debe devolver JSON con `serverInfo.name: "codegraph"`.

### Notas
- `CODEGRAPH_NO_DAEMON=1` evita el intento de daemon (falla siempre en Android) y va directo a modo in-process
- En modo in-process cada invocación crea un nuevo engine; no hay compartición entre sesiones, pero en Termux no es problema
- CodeGraph versión 0.9.5+, Node.js v24+
