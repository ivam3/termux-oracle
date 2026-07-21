# termux-oracle-skill

## Descripción
`termux-oracle-skill` es la skill (habilidad) principal diseñada para proporcionar a los agentes de IA un conocimiento profundo sobre el ecosistema Termux, las limitaciones de Android (bionic vs glibc) y la suite de herramientas de i-HakLab.

## Funcionalidades
- **Detección del Entorno**: Permite al agente analizar si está corriendo en Termux nativo, proot-distro, etc.
- **Resolución de Problemas**: Ayuda al agente a saber cuándo usar `pkg` vs `apt`, cómo evitar errores de dependencias (por ejemplo, con herramientas de Python y C), y cuándo recurrir a alternativas como `udocker` o `proot`.
- **Acceso a Documentación**: Sirve de índice para que el agente consulte toda la base de conocimiento de i-HakLab (manuales, configuraciones, wrappers, etc.).

## Uso
Esta herramienta es de uso interno para los agentes de Inteligencia Artificial (como Antigravity, OpenCode, Claude Code) cuando operan en el entorno de Termux configurado por i-HakLab.
