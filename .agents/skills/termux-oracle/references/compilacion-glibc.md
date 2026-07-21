# Compilación y Adaptación de Herramientas glibc

Android usa **Bionic libc**, no GNU glibc. Binarios Linux precompilados fallan con `CANNOT LINK EXECUTABLE` o `segfault`.

## Patrón de Adaptación Ivam3 (C Wrapper + .va39)

### 1. El binario real oculto
El binario original arm64/glibc se renombra con extensión `.va39`.

### 2. El cargador glibc aislado
Se usa `$PREFIX/glibc/lib/ld-linux-aarch64.so.1` como linker.

### 3. Bootstrapper en C (`*_helper.c`)
Se compila un wrapper en C que:
1. Limpia `LD_PRELOAD` y `LD_LIBRARY_PATH`
2. Configura `GLIBC_TUNABLES`
3. Ejecuta el binario `.va39` via el loader glibc

```c
int main(int argc, char *argv[]) {
    unsetenv("LD_PRELOAD");
    unsetenv("LD_LIBRARY_PATH");
    setenv("GLIBC_TUNABLES", "glibc.rtld.dynamic_sort=1", 1);
    char *exec_args[] = {
        "/data/data/com.termux/files/usr/glibc/lib/ld-linux-aarch64.so.1",
        "/data/data/com.termux/files/home/.local/share/claude-code/claude-code.va39",
        NULL
    };
    execv(exec_args[0], exec_args);
    return 1;
}
```

## Herramientas que usan este patrón
`claude-code`, `opencode`, `codebuff`, `freebuff`, `mimocode`, `mistral-vibe`, `antigravity-cli`

## Método legacy: proot-distro
Antes se usaba `proot-distro alpine` como wrapper:
```bash
proot-distro install alpine
proot-distro login alpine -- opencode "$@"
```
Los paquetes actuales (julio 2026+) reemplazaron proot por helper C + loader glibc.

## Comparativa de métodos
| Aspecto | Nativo glibc (helper.c) | proot-distro | npm/pnpm |
|---------|------------------------|--------------|----------|
| Rendimiento | Máximo | Medio | Medio-alto |
| Latencia arranque | ~0ms | ~1-3s | ~100ms |
| Dependencias | glibc, clang, python | proot-distro + Alpine | nodejs |
