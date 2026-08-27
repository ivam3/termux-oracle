# nls

## ¿Qué es nls?

**nls** es un listador de archivos y directorios al estilo **Nushell**, diseñado para usarse en shells estándar (bash, fish, zsh) sin necesidad de Nushell. Presenta la salida en columnas estructuradas con soporte de colores, iconos, estado Git, tamaños legibles y salida JSON. Es el reemplazo mejorado de `ls` en i-HakLab, especialmente adaptado para pantallas pequeñas de Android.

> [!NOTE]
> En i-HakLab el comando `ls` está redirigido a `lsd` (un `ls` moderno con iconos y colores). `nls` va un paso más allá ofreciendo formato tabular estructurado estilo Nushell, útil cuando se necesita información detallada en columnas alineadas.

## ¿Para qué es útil la herramienta?

- **Listado enriquecido:** Muestra archivos con iconos, colores por tipo, tamaños legibles y permisos en formato columnar.
- **Estado Git integrado:** Muestra el estado git de cada archivo (`-g`) sin necesidad de `git status`.
- **Salida JSON:** Exporta el listado como JSON (`--json`) para pipelines y scripts.
- **Formato tabla:** Visualización estructurada (`--table`) ideal para directorios con muchos archivos.
- **Tamaño exacto de directorios:** Calcula el tamaño real recursivo de carpetas (`-P`).
- **Pantallas Android:** La salida columnar es más legible que `ls` estándar en terminales pequeñas.

## Instalación en Termux (i-HakLab)

`nls` es un binario Go instalado automáticamente con i-HakLab en `~/go/bin/nls`.

```bash
# Si no está instalado, instalar manualmente:
go install github.com/nicholasgasior/nls@latest
# o via apt en el ecosistema i-HakLab:
apt install i-haklab
```

## ¿Cómo se usa? (Ejemplos básicos)

**Ejemplo 1: Listar directorio actual (formato tabla)**

```bash
nls --table
```

**Ejemplo 2: Listar con archivos ocultos**

```bash
nls -a
```

**Ejemplo 3: Vista larga con metadatos extendidos**

```bash
nls -l
```

**Ejemplo 4: Mostrar estado Git de cada archivo**

```bash
nls -g
```

**Ejemplo 5: Ordenar por tamaño**

```bash
nls -S
```

**Ejemplo 6: Listar recursivamente**

```bash
nls -R ~/proyecto
```

**Ejemplo 7: Salida JSON (para scripts/pipelines)**

```bash
nls --json | jq '.[].name'
```

**Ejemplo 8: Tamaño exacto de directorios**

```bash
nls -l -P
```

**Ejemplo 9: Sin colores (para pipes o logs)**

```bash
nls --plain --no-color
```

**Ejemplo 10: Agrupar directorios primero**

```bash
nls --group-directories-first
```

## Opciones principales

| Flag | Descripción |
|------|-------------|
| `-a`, `--all` | Muestra archivos ocultos (`.`) |
| `-A`, `--almost-all` | Como `-a` pero omite `.` y `..` |
| `-l`, `--long` | Metadatos extendidos (permisos, dueño, tamaño, fecha) |
| `-g`, `--git-status` | Estado git de cada archivo |
| `-h`, `--human-readable` | Tamaños legibles (KB, MB, GB) |
| `-S`, `--size` | Ordenar por tamaño |
| `-t`, `--time` | Ordenar por fecha de modificación |
| `-R`, `--recursive` | Listar recursivamente |
| `-r`, `--reverse` | Orden inverso |
| `-1`, `--one` | Un archivo por línea |
| `-P`, `--precise` | Calcula tamaño exacto de directorios |
| `--table` | Salida en formato tabla |
| `--json` | Salida en JSON |
| `--no-color` | Sin colores |
| `--no-icons` | Sin iconos |
| `--plain` | Texto plano sin formato |
| `--group-directories-first` | Directorios primero |

## Diferencias con `ls` y `lsd`

| Característica | `ls` (nativo) | `lsd` (wrapper `ls` en i-HakLab) | `nls` |
|----------------|--------------|----------------------------------|-------|
| Colores | Básicos | ✅ Con iconos | ✅ Con iconos |
| Formato tabla estructurada | ❌ | ❌ | ✅ |
| Salida JSON | ❌ | ❌ | ✅ |
| Estado Git | ❌ | ❌ | ✅ |
| Tamaño exacto de dirs | ❌ | ❌ | ✅ |
| Estilo Nushell | ❌ | ❌ | ✅ |

## Referencias

- Repositorio: [nicholasgasior/nls](https://github.com/nicholasgasior/nls) *(Go binary)*
- Mencionado en: `i-HakLab help` como reemplazo mejorado de `ls`

---
*Esta herramienta es parte del ecosistema i-HakLab para Android/Termux.*
