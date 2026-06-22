# Open-Lovable

## ¿Qué es Open-Lovable?

**Open-Lovable** es una aplicación web basada en **Next.js** diseñada para desarrollo rápido de interfaces modernas. Utiliza tecnologías como React, Turbopack y pnpm para mejorar el rendimiento en desarrollo.

## ¿Para qué es útil?

* Desarrollo frontend moderno
* Prototipado rápido
* Aplicaciones web escalables
* Uso en entornos locales y cloud

## Ejecución en modo desarrollo

```bash
${HOME}/.local/share/open-lovable && pnpm dev
```

## Consideraciones en Termux

Turbopack no es compatible con Android
Es necesario deshabilitar Turbopack usando:
NEXT_DISABLE_TURBOPACK=1
Requiere Node.js reciente

## Instalación mediante los wrappers de i-HakLab

Los wrappers `apt`, `npm` y `pnpm` de i-HakLab automatizan la instalación de open-lovable:

1.  Eliminan una instalación previa en `~/.local/share/open-lovable` si existe.
2.  Clonan el repositorio oficial desde `github.com/firecrawl/open-lovable` en esa ruta.
3.  Habilitan `corepack` para garantizar la versión correcta de pnpm.
4.  Ejecutan `pnpm install` o `pnpm update` desde el directorio clonado.

Este flujo asegura que open-lovable se instale desde la fuente oficial con las dependencias adecuadas para Termux. Consulta `npm.md` o `pnpm.md` para más detalles.
