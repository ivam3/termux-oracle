# Code Companion (codecompanion.nvim)

## ¿Qué es Code Companion?

**Code Companion** (repositorio: `olimorris/codecompanion.nvim`) es un plugin de Neovim que integra asistentes de inteligencia artificial directamente en el editor. Permite conversar con modelos de lenguaje (como Claude, OpenAI, Gemini, etc.) sin salir de Neovim, facilitando la generación, explicación y refactorización de código en tiempo real.

## ¿Para qué es útil?

- **Chat con IA:** Conversar con un asistente sobre el código abierto en el buffer actual.
- **Acciones en línea:** Seleccionar código y pedir explicaciones, refactorización o tests sin copiar/pegar.
- **Autocompletado inteligente:** Sugerencias de código basadas en el contexto del proyecto.
- **Vibe coding:** Flujo continuo de edición asistida dentro de Neovim.

## Instalación

Code Companion se instala automáticamente como parte de la configuración de Neovim en i-HakLab mediante el orquestador `pkg2conf`:

```bash
# Instalar Neovim (incluye Code Companion y demás plugins):
apt install neovim
```

Los plugins (incluyendo Code Companion) se gestionan a través de `lazy.nvim` y se configuran en `~/.config/nvim/lua/plugins/`.

## Atajos de teclado en i-HakLab

| Atajo | Acción |
| :--- | :--- |
| `<A-,>ca` | Abrir acciones de Code Companion |
| `<A-,>cc` | Abrir chat de Code Companion |
| `<A-,>ci` | Code Companion Inline (vibe coding) |
| `<A-,>ce` | Explicar código seleccionado |

## Consideraciones Adicionales

- Requiere una API key del proveedor de IA configurada en las variables de entorno.
- Se integra con múltiples proveedores: OpenAI, Anthropic Claude, Google Gemini, Azure OpenAI, Ollama (local).
- El plugin se actualiza automáticamente al actualizar Neovim mediante `pkg2conf`.

---

*Nota: Plugin integrado en la configuración de Neovim del ecosistema i-HakLab.*
