# Compilación y Adaptación de Herramientas Glibc (`claude-code`, `opencode`) 🛠️

Este documento describe el patrón arquitectónico avanzado de desarrollo y adaptación de binarios nativos desarrollado en la comunidad **Ivam3bycinderella**, el cual permite ejecutar herramientas de vanguardia diseñadas originalmente para entornos Linux estándar (`glibc`) dentro del entorno nativo de Termux (`bionic libc`), tales como **claude-code**, **opencode** y **antigravity-cli**.

---

## 🔬 El Desafío Técnico en Android/Termux
Android no utiliza la librería estándar de C de GNU (`glibc`), sino su propia implementación optimizada para móviles llamada **Bionic libc**. 

### El Problema:
Cuando descargas un binario precompilado de herramientas avanzadas de IA (como las versiones de Node/CLI de `claude-code` u `opencode`), estos binarios vienen enlazados dinámicamente contra `glibc`. Si intentas ejecutarlos directamente en Termux, obtendrás errores inmediatos de entorno como:
* `Linker error: CANNOT LINK EXECUTABLE`
* fallos de segmentación (`Segmentation fault`)
* incompatibilidad con los cargadores del sistema de Android.

---

## 🛠️ El Patrón de Adaptación Ivam3 (C Wrapper + Real Binary `.va39`)
Para solucionar esta limitación estructural sin necesidad de usar entornos pesados como `proot` o `chroot`, se diseñó un **patrón de inyección y aislamiento nativo** que consta de tres componentes:

### 1. El Binario Real Oculto
El binario original compilado para arquitecturas `arm64` bajo Linux/glibc se descarga y se renombra internamente con una extensión o nomenclatura especial (por ejemplo, añadiendo `.va39` o guardándolo en un subdirectorio aislado del entorno).

### 2. El Cargador Glibc Aislado
Se despliega un entorno `glibc` ligero embebido (a través de un tarball o biblioteca específica) dentro de los directorios de datos de la herramienta en Termux, asegurando que el binario tenga acceso a un *Linker* y librerías compatibles.

### 3. El Bootstrapper / Wrapper en C (`claudecode_helper.c`)
Se compila localmente en el dispositivo un puente en lenguaje C que intercepta la ejecución, limpia el entorno de Android para evitar colisiones y delega el control al cargador glibc.

#### Código Esquemático del Wrapper:
```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    // 1. Limpiar variables de entorno que causan conflicto entre Bionic (Android) y Glibc
    unsetenv("LD_PRELOAD");
    unsetenv("LD_LIBRARY_PATH");

    // 2. Configurar el entorno de ejecución glibc aislado
    setenv("GLIBC_TUNABLES", "glibc.rtld.dynamic_sort=1", 1);

    // 3. Ejecutar el binario real a través del cargador glibc específico
    char *exec_args[] = {
        "/data/data/com.termux/files/usr/glibc/lib/ld-linux-aarch64.so.1",
        "/data/data/com.termux/files/home/.local/share/claude-code/claude-code.va39",
        NULL
    };

    // Unir argumentos pasados por el usuario...
    execv(exec_args[0], exec_args);

    // Si execv falla
    perror("Error al arrancar la adaptación nativa de Glibc");
    return 1;
}
```

---

## 🚀 El Proceso de Automatización (`postinst`)
El despliegue de estas herramientas se empaqueta en archivos `.deb` autogestionados mediante un script de post-instalación (`postinst`) que realiza las siguientes tareas de forma autónoma en el dispositivo:

1. **Descubrimiento de Versión:** Consulta las APIs oficiales para identificar el último lanzamiento estable de la herramienta (`claude-code` u `opencode`).
2. **Descarga y Extracción:** Baja el binario correspondiente a `arm64 glibc` y lo posiciona en la partición interna.
3. **Compilación Local:** Invoca a `clang` dentro de Termux para compilar el código del helper o wrapper de C asegurando que los paths locales queden hardcodeados de manera exacta.
4. **Asignación de Permisos:** Corrige los privilegios de ejecución (`chmod +x`) tanto del wrapper público como del binario `.va39` subyacente.

---

## 📊 Comparativa: Métodos de adaptación para agentes AI

| Aspecto | Nativo glibc (helper.c) ✅ | proot-distro (legacy) | npm/pnpm |
|---------|---------------------------|----------------------|----------|
| **Rendimiento** | Máximo (ejecución directa) | Medio (overhead proot) | Medio-alto |
| **Arquitectura** | Solo aarch64 | Todas (arm, i686, x86_64) | Todas |
| **Señales/procesos** | Completo | Limitado (proot no pasa todas las syscalls) | Completo |
| **Integración FS** | Directa con Termux | Aislada en `$PREFIX/var/lib/proot-distro/installed-rootfs/` | Directa |
| **Latencia arranque** | ~0ms | ~1-3s (inicio proot) | ~100ms |
| **Helper C** | Sí, compila `*_helper.c` | No | No |
| **Dependencias** | glibc, clang, python | proot-distro + Alpine/Ubuntu | nodejs |
| **Caso de uso** | Producción, uso diario | Testing, compatibilidad cruzada | Usuarios sin ivam3 repo |

### Método legacy: proot-distro

Las versiones anteriores de los paquetes (`claude-code`, `opencode`) usaban proot-distro con Alpine Linux:

```bash
proot-distro install alpine
proot-distro login alpine -- opencode "$@"
```

El script wrapper era un simple bash que hacía:
```bash
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login alpine -- /usr/bin/opencode "$@"
```

**Migración**: Los paquetes actuales (julio 2026+) reemplazaron proot por el helper C + loader glibc. Si actualizas desde una versión anterior, el `postinst` elimina el directorio proot antiguo automáticamente.

---

## 💡 Impacto en DeepWiki / Asistentes IA
Gracias a este patrón de documentación, el asistente (DevinAI) comprende que:
* `claude-code` y `opencode` en i-HakLab **no corren de forma tradicional**, sino que emplean un wrapper en C para aislar `LD_PRELOAD`.
* Si un usuario reporta un error de permisos o un crash al iniciar estas herramientas de IA, el primer paso de depuración consiste en verificar la correcta compilación del helper y la presencia del cargador `/usr/glibc/lib/ld-linux-aarch64.so.1`.
