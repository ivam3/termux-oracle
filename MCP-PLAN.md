# Plan: Servidor MCP para termux-oracle

## 1. Visión General

Convertir **termux-oracle** (la base de conocimiento de i-HakLab) en un **Servidor MCP (Model Context Protocol)** que permita a agentes de IA —como OpenCode, Claude Code, Cline, etc.— consultar documentación, obtener instrucciones de instalación y ejecutar comandos del ecosistema i-HakLab de forma estructurada y agéntica.

**Stack:** Python con `mcp` (SDK oficial), SQLite FTS5 para indexación, sin dependencias externas pesadas.

---

## 2. Estructura del Proyecto

```
/data/data/com.termux/files/.repositories/termux-oracle/
├── MCP-PLAN.md                 # Este documento
├── mcp-server/
│   ├── server.py               # Punto de entrada MCP
│   ├── pyproject.toml           # Configuración del proyecto Python
│   ├── README.md               # Cómo usar el MCP Server
│   └── src/
│       ├── __init__.py
│       ├── indexer.py           # Indexa los .md en SQLite FTS5
│       ├── resources.py         # Define los recursos MCP (URIs)
│       ├── tools.py             # Define las herramientas MCP
│       ├── prompts.py           # Prompts reutilizables
│       └── models.py            # Tipos de datos (Pydantic)
├── docs/                        # (sin cambios — la KB existente)
└── tests/
    ├── test_indexer.py
    ├── test_parser.py
    ├── test_tools.py
    └── test_resources.py
```

---

## 3. Recursos MCP (Contexto Pasivo)

URIs que el agente puede consultar como contexto:

| URI | Contenido |
|-----|-----------|
| `termux://docs/herramientas/{name}` | Documentación completa de una herramienta |
| `termux://docs/index` | Índice alfabético de las 190+ herramientas |
| `termux://docs/ihaklab/manual` | Manual completo de i-HakLab |
| `termux://docs/ihaklab/wrappers` | Comportamiento de wrappers apt/npm/pnpm |
| `termux://docs/termux/{topic}` | Guía de Termux (paquetes, ssh, git, etc.) |
| `termux://docs/categoria/{name}` | Documentación de una categoría (android, ctf, scripts...) |
| `termux://search?q={query}` | Resultados de búsqueda FTS5 |

---

## 4. Tools MCP (Acciones Activas)

Herramientas que el agente puede invocar:

| Tool | Argumentos | Retorno |
|------|-----------|---------|
| `get_tool_info` | `tool_name: str` | Qué es, para qué sirve, ejemplos de uso, instalación |
| `search_docs` | `query: str, limit: int` | Lista de documentos con fragmentos relevantes |
| `get_install_method` | `tool_name: str` | Comando(s) exactos de instalación (apt/pip/npm/gem) |
| `list_tools_by_category` | `category: str` | Filtra herramientas por área (OSINT, pentest, IA, Android, redes) |
| `get_wrapper_behavior` | `tool_name: str` | Explica cómo el wrapper redirige apt → pip/npm/gem |
| `get_default_credentials` | — | Login por defecto, credenciales 4share, servers4test |
| `get_api_keys_info` | — | APIs configurables y dónde obtener las keys |
| `get_i_haklab_command` | `command: str` | Ayuda detallada de un subcomando de i-HakLab |

---

## 5. Indexación y Búsqueda (SQLite FTS5)

### Esquema de la tabla de búsqueda

```sql
CREATE VIRTUAL TABLE docs_index USING fts5(
  title,        -- Título H1
  section,      -- Nombre de sección H2
  content,      -- Texto completo de la sección
  category,     -- Directorio padre (herramientas, termux, android...)
  filepath,     -- Ruta relativa desde docs/
  tokenize='porter unicode61'
);
```

### Indexador (`src/indexer.py`)

```python
class DocIndexer:
    def __init__(self, db_path: str = "termux_oracle.db"):
        self.db_path = db_path

    def build_index(self, docs_root: str):
        """Escanea docs/, parsea cada .md, construye FTS5"""
        ...

    def search(self, query: str, limit: int = 10) -> list[SearchResult]:
        ...
```

**Flujo:**
1. Escanea `docs/` recursivamente
2. Por cada `.md`, extrae secciones (H1 → H2 → contenido)
3. Separa bloques de código, texto, y listas
4. Alimenta la tabla FTS5
5. Se reconstruye al iniciar el servidor (o se cachea en disco)

---

## 6. Estrategia de Parseo de Documentación de Herramientas

Las tool docs siguen una estructura consistente (analizada sobre 190+ archivos). El parseo extrae:

```python
@dataclass
class ToolDoc:
    name: str               # H1
    what_is: str            # primer H2 (¿Qué es?)
    use_cases: list[str]    # segundo H2 (¿Para qué es útil?)
    usage_examples: list[CodeExample]  # bloques de código
    installation: list[str]           # de la sección Instalación
    considerations: str               # último H2
    install_type: InstallType         # apt | pip | npm | gem | wrapper
```

**Detector de tipo de instalación:**

Derivado de `docs/recursos/herramientas/apt.md` y `docs/recursos/herramientas-ihaklab.md`:

```python
INSTALL_MAP = {
    # Pip
    "sqlmap": InstallType("python3 -m pip install sqlmap"),
    "shodan": InstallType("python3 -m pip install shodan"),
    "bloodhound": InstallType("python3 -m pip install bloodhound"),
    "frida": InstallType("pip install frida-tools"),
    "wfuzz": InstallType("python3 -m pip install wfuzz"),
    "mvt": InstallType("pip install mvt"),
    "holehe": InstallType("pip install holehe"),
    "sherlock": InstallType("pip install sherlock"),
    "hashid": InstallType("pip install hashid"),
    # Gem
    "bettercap": InstallType("gem install bettercap"),
    "aquatone": InstallType("gem install aquatone"),
    # Npm
    "copilot-cli": InstallType("npm install -g @github/copilot"),
    "claude-code": InstallType("npm install -g @anthropic-ai/claude-code"),
    "opencode": InstallType("npm install -g opencode-ai"),
    "gemini-cli": InstallType("npm install -g @google/gemini-cli"),
    "qwen-code": InstallType("npm install -g @qwen-code/qwen-code"),
    "minimax-cli": InstallType("npm install -g mmx-cli"),
    "mimocode": InstallType("npm install -g mimocode"),
    "codex": InstallType("npm install -g @mmmbuto/codex-cli-termux@latest"),
    "localtunnel": InstallType("npm install -g localtunnel"),
    "n8n": InstallType("npm install -g n8n"),
    # Apt nativo
    "nmap": InstallType("apt install nmap"),
    "amass": InstallType("apt install amass"),
    "metasploit-framework": InstallType("apt install metasploit-framework"),
    "beef": InstallType("apt install beef"),
    "openclaw": InstallType("apt install openclaw"),
    "antigravity-cli": InstallType("apt install antigravity-cli"),
}
```

---

## 7. Prompts MCP (Pre-escritos)

```python
@server.prompt()
def tool_advisor(tool_name: str) -> Message:
    """
    Prompt que guía al AI a actuar como experto en i-HakLab.
    Contexto: propósito, instalación, ejemplos, advertencias.
    """

@server.prompt()
def troubleshoot_issue(symptom: str) -> Message:
    """
    Prompt de diagnóstico basado en docs/termux/troubleshooting.md.
    """
```

---

## 8. Configuración de opencode.json

El usuario registra el MCP en su `opencode.json`:

```json
{
  "mcpServers": {
    "termux-oracle": {
      "command": "python",
      "args": ["mcp-server/server.py"],
      "env": {}
    }
  }
}
```

---

## 9. Plan de Implementación por Fases

### Fase 1: Base (duración estimada: 2-3 horas)

| Archivo | Responsabilidad |
|---------|----------------|
| `mcp-server/pyproject.toml` | Dependencias (`mcp>=1.0.0`, `pydantic`) |
| `mcp-server/server.py` | `FastMCP` entry point, registro de recursos/tools/prompts |
| `mcp-server/src/indexer.py` | Escaneo de docs/, parseo de .md, construcción de SQLite FTS5 |
| `mcp-server/src/models.py` | `ToolDoc`, `SearchResult`, `InstallType` (Pydantic) |
| `mcp-server/src/__init__.py` | Package init |
| `mcp-server/README.md` | Instrucciones de uso |
| `tests/test_indexer.py` | Tests del indexador |
| `tests/test_parser.py` | Tests del parseo de markdown |

### Fase 2: Tools Core (2-3 horas)

| Archivo | Tool |
|---------|------|
| `mcp-server/src/resources.py` | `termux://docs/herramientas/`, `termux://docs/index`, `termux://search?q=` |
| `mcp-server/src/tools.py` | `get_tool_info()`, `search_docs()`, `get_install_method()`, `list_tools_by_category()` |
| `tests/test_tools.py` | Tests de las tools |

### Fase 3: Tools Avanzadas (1-2 horas)

| Tool | Fuente de datos |
|------|----------------|
| `get_wrapper_behavior()` | `docs/recursos/herramientas-ihaklab.md` (sección 13) + `docs/recursos/herramientas/apt.md` |
| `get_default_credentials()` | `docs/recursos/herramientas-ihaklab.md` (sección 14) |
| `get_api_keys_info()` | `docs/recursos/herramientas-ihaklab.md` (sección 13) + `docs/termux/variables-y-api-keys.md` |
| `get_i_haklab_command()` | `docs/recursos/herramientas-ihaklab.md` (secciones 8-10) |

### Fase 4: Testing y Validación (1 hora)

```bash
# Verificar que el servidor inicia
python -m mcp run mcp-server/server.py

# Probar con MCP Inspector
npx @modelcontextprotocol/inspector python mcp-server/server.py

# Tests unitarios
python -m pytest tests/ -v
```

---

## 10. Mapa de Fuentes de Datos

| Tool / Recurso | Archivo(s) Fuente |
|----------------|-------------------|
| `get_tool_info()` | `docs/recursos/herramientas/{tool}.md` |
| `search_docs()` | Índice SQLite FTS5 construido de toda `docs/` |
| `get_install_method()` | `docs/recursos/herramientas/apt.md` + tabla hardcodeada |
| `list_tools_by_category()` | `docs/recursos/herramientas/herramientas.md` (sección 12) + directorios |
| `get_wrapper_behavior()` | `docs/recursos/herramientas-ihaklab.md` §13 + `docs/recursos/herramientas/apt.md` |
| `get_default_credentials()` | `docs/recursos/herramientas-ihaklab.md` §14 |
| `get_api_keys_info()` | `docs/recursos/herramientas-ihaklab.md` §13 + `docs/termux/variables-y-api-keys.md` |
| `get_i_haklab_command()` | `docs/recursos/herramientas-ihaklab.md` §§8-10 |
| Recurso herramientas | `docs/recursos/herramientas/README.md` |
| Recurso manual i-HakLab | `docs/recursos/herramientas-ihaklab.md` |

---

## 11. Comparativa con DeepWiki (actual)

| Aspecto | DeepWiki / DevinAI | MCP Server (propuesto) |
|---------|-------------------|----------------------|
| Tipo de acceso | Indexación pasiva del repo | Consultas activas estructuradas |
| Respuesta | Texto plano del .md | Datos parseados por secciones |
| Instalación | Sabe leer "Instalación" si existe | Resuelve wrapper apt→pip/npm/gem aunque no esté en el .md |
| Búsqueda | Limitada a lo que DeepWiki indexó | FTS5 local con control total |
| Interacción | Solo lectura de docs | Puede exponer ejecución de comandos i-HakLab |
| Latencia | Depende de API de DeepWiki | Local, sin red |
| Privacidad | Documentos públicos | Funciona 100% offline |
| Categorización | Por estructura del repo | Por metadata explícita + tabla de instalación |

---

## 12. Dependencias (pyproject.toml)

```toml
[project]
name = "mcp-server-termux-oracle"
version = "0.1.0"
description = "MCP Server for termux-oracle / i-HakLab knowledge base"
requires-python = ">=3.10"
dependencies = [
    "mcp>=1.0.0",
    "pydantic>=2.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0",
    "pytest-asyncio>=0.21",
]
```

SQLite FTS5 no requiere dependencia externa — viene incluido en `sqlite3` de la stdlib de Python.

---

## 13. Riesgos y Mitigaciones

| Riesgo | Mitigación |
|--------|-----------|
| Un tool doc no tiene sección "Instalación" | El `get_install_method()` cae en la tabla hardcodeada de wrappers |
| El formato markdown varía entre archivos | El parser es tolerante: busca por keywords de H2, no por posición fija |
| SQLite FTS5 no disponible en Python | `sqlite3` lo incluye desde Python 3.6+; verificar con `pragma compile_options` |
| Escalabilidad con 190+ archivos | El índice se construye en <1s; búsqueda FTS5 es sub-milisegundo |
| Path del repo cambia | Usar `$PWD` relativo o variable de entorno `TERMUX_ORACLE_PATH` |

---

## 14. Próximos Pasos (después de este plan)

1. Implementar Fase 1 (Base): `pyproject.toml`, `server.py`, `indexer.py`, `models.py`
2. Implementar Fase 2 (Tools Core): `resources.py`, `tools.py` con las 4 tools principales
3. Probar con `npx @modelcontextprotocol/inspector`
4. Agregar las tools avanzadas de Fase 3
5. Escribir tests y documentación de uso
