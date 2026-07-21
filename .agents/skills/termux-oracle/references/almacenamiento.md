# Acceso al Almacenamiento en Termux

## Comando principal
```bash
termux-setup-storage
```
Android pedirá permiso — seleccionar **Permitir**. Crea `~/storage/` con enlaces simbólicos.

## Estructura de `~/storage`
| Enlace | Destino |
|--------|---------|
| `~/storage/shared` | `/sdcard` (raíz memoria interna) |
| `~/storage/downloads` | `/sdcard/Download` |
| `~/storage/pictures` | `/sdcard/Pictures` |
| `~/storage/dcim` | `/sdcard/DCIM` |
| `~/storage/movies` | `/sdcard/Movies` |
| `~/storage/external-1` | Tarjeta SD externa (si existe) |

## Privado vs Compartido
| Característica | `$HOME` (privado) | `/sdcard` (compartido) |
|---|---|---|
| Permisos exec | ✅ Soporta `chmod +x` | ❌ `noexec` |
| Enlaces simbólicos | ✅ | ❌ |
| `git clone` | ✅ | ❌ |
| Persistencia | Se borra al desinstalar Termux | Intacto |

**NUNCA** hacer `git clone` ni compilar dentro de `/sdcard` o `~/storage/shared`.

## Solución a errores de permisos
1. Ajustes Android → Apps → Termux → Permisos
2. Revocar y reconceder "Permiso de almacenamiento"
3. En Termux: `termux-setup-storage`

## Tarjetas SD externas (Android 10+)
- Solo **lectura** en la raíz de la SD externa
- **Escritura** solo en: `/storage/XXXX-XXXX/Android/data/com.termux/files/`
