# proroot

## ¿Qué es proroot?

**proroot** es un wrapper simplificado de `proot-distro` que permite instalar y gestionar distribuciones Linux (Debian, Ubuntu, Kali, Alpine) dentro de Termux de forma rápida e interactiva. A diferencia del `proot` tradicional, proroot está diseñado para un flujo de trabajo más directo con menor configuración manual.

> [!NOTE]
> No confundir con `proot` (el binario de syscall-intercept) ni con `proot-distro` (el gestor oficial de Termux). **proroot** es el wrapper de i-HakLab que simplifica su uso.

## ¿Para qué es útil la herramienta?

- **Entornos Linux completos en Android:** Levanta distros completas con gestor de paquetes nativo (`apt`, `apk`, etc.) sin root.
- **Laboratorios de seguridad:** Ejecuta herramientas que requieren glibc completa (Kali, Debian) sin adaptaciones adicionales.
- **Desarrollo multiplataforma:** Prueba código en entornos Linux reales sin salir de Termux.
- **Integración con X11:** Compatible con `i-HakLab Xwayland` para entorno gráfico dentro de la distro.

## Instalación en Termux (i-HakLab)

```bash
apt install proroot
```

Requiere `proot-distro` como dependencia (se instala automáticamente).

## ¿Cómo se usa? (Ejemplos básicos)

**Ejemplo 1: Ver distribuciones disponibles**

```bash
proroot list
```

**Ejemplo 2: Instalar una distribución**

```bash
proroot install debian
proroot install kali-nethunter
proroot install alpine
```

**Ejemplo 3: Entrar a la distribución instalada**

```bash
proroot login debian
```

**Ejemplo 4: Ejecutar comando dentro de la distro**

```bash
proroot run debian -- apt update
```

**Ejemplo 5: Ver ayuda**

```bash
proroot --help
```

## Diferencias con proot-distro

| Característica | `proot-distro` | `proroot` |
|----------------|---------------|-----------|
| Interfaz | Extensa | Simplificada |
| Gestión de distros | Completa | Subconjunto curado |
| Integración i-HakLab | Parcial | Total |
| Comando principal | `proot-distro login <distro>` | `proroot login <distro>` |

## Desinstalación

```bash
apt remove proroot
```

## Referencias

- Repositorio: [ivam3/proroot](https://github.com/Ivam3/proroot)
- Soporte: [t.me/Ivam3_Bot](https://t.me/Ivam3_Bot)

---
*Esta herramienta es parte del ecosistema i-HakLab para Android/Termux.*
