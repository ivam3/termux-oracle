# testsprite (TestSprite MCP)

## ¿Qué es testsprite?

**TestSprite** es un servidor MCP (Model Context Protocol) que integra capacidades de generación y ejecución automatizada de pruebas de software directamente en el flujo de trabajo de agentes de IA. Permite a asistentes como Antigravity CLI, OpenCode o Claude Code generar planes de prueba, ejecutar tests y ver resultados sin salir del entorno de codificación.

## ¿Para qué es útil la herramienta?

- **Generación automática de tests:** El agente crea suites de prueba (unitarias, de integración, E2E) basadas en el código fuente.
- **Ejecución desde el agente:** Los tests se ejecutan directamente desde la sesión de codificación asistida.
- **Dashboard de resultados:** Abre un panel web con los resultados de cada ejecución.
- **PRDs y summaries:** Genera documentos de requerimientos y resúmenes de código automáticamente.
- **Integración MCP:** Compatible con cualquier agente que soporte el protocolo MCP.

## Instalación en Termux (i-HakLab)

```bash
apt install testsprite
# o directamente:
npm install -g @testsprite/testsprite-mcp
```

## Configuración en Antigravity CLI

TestSprite se configura como MCP server en `~/.gemini/antigravity-cli/mcp_config.json`:

```json
{
  "mcpServers": {
    "testsprite": {
      "command": "node",
      "args": ["~/.local/share/testsprite/index.js"],
      "env": {
        "TESTSPRITE_API_KEY": "<tu-api-key>"
      }
    }
  }
}
```

## Herramientas MCP disponibles

| Tool | Descripción |
|------|-------------|
| `testsprite_bootstrap` | Inicializa TestSprite en el proyecto |
| `testsprite_generate_code_summary` | Genera resumen del código |
| `testsprite_generate_standardized_prd` | Crea PRD estándar del proyecto |
| `testsprite_generate_frontend_test_plan` | Plan de pruebas frontend |
| `testsprite_generate_backend_test_plan` | Plan de pruebas backend |
| `testsprite_generate_code_and_execute` | Genera y ejecuta tests |
| `testsprite_open_test_result_dashboard` | Abre dashboard de resultados |
| `testsprite_check_account_info` | Verifica estado de la cuenta |

## ¿Cómo se usa?

TestSprite se usa principalmente a través del agente de IA. En modo MCP el agente invoca las herramientas automáticamente. También puede invocarse directamente:

```bash
# Ver ayuda
testsprite --help

# Bootstrap en un proyecto
cd mi-proyecto
testsprite bootstrap
```

## Obtener API Key

Regístrate en [testsprite.com](https://testsprite.com) para obtener tu API key y configurarla en el entorno:

```bash
export TESTSPRITE_API_KEY="tu-api-key-aqui"
```

## Referencias

- Web oficial: [testsprite.com](https://testsprite.com)
- NPM: [@testsprite/testsprite-mcp](https://www.npmjs.com/package/@testsprite/testsprite-mcp)
- Soporte: [t.me/Ivam3_Bot](https://t.me/Ivam3_Bot)

---
*Esta herramienta es parte del ecosistema i-HakLab para Android/Termux.*
