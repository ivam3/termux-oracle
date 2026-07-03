# Codebuff CLI (codebuff)

## ¿Qué es Codebuff?

**Codebuff** es un asistente de inteligencia artificial de código abierto para la terminal que utiliza una arquitectura multi-agente para editar tu código base mediante instrucciones en lenguaje natural. A diferencia de herramientas que usan un solo modelo, Codebuff coordina agentes especializados (File Picker, Planner, Editor, Reviewer) que trabajan juntos para entender tu proyecto y realizar cambios precisos. Soporta cualquier modelo disponible en OpenRouter (Claude, GPT, DeepSeek, etc.).

## ¿Para qué es útil la herramienta?

Codebuff está diseñado para la edición de código compleja y la automatización de flujos de desarrollo:

*   **Edición Multi-agente:** Agentes especializados que escanean la arquitectura, planean cambios, editan archivos y revisan resultados.
*   **Agentes Personalizados:** Crea tus propios agentes con TypeScript, definiendo herramientas, subagentes y flujos de trabajo (`/init`).
*   **SDK para Producción:** El paquete `@codebuff/sdk` permite integrar Codebuff en aplicaciones, CI/CD y pipelines de desarrollo.
*   **Cualquier Modelo en OpenRouter:** Cambia entre Claude, GPT, Qwen, DeepSeek y otros sin esperar actualizaciones de la plataforma.
*   **Gestión de Git y Terminal:** Capacidad para ejecutar comandos, instalar paquetes y ejecutar tests automáticamente.

## Instalación

```bash
# Mediante el wrapper de i-HakLab (redirige automáticamente a npm):
apt install codebuff
# O directamente con npm:
npm install -g codebuff
```

## ¿Cómo se usa? (Ejemplos básicos)

Una vez instalado, puedes iniciar la sesión interactiva en el directorio de tu proyecto:

**Ejemplo 1: Iniciar Codebuff en el directorio actual**

```bash
cd tu-proyecto
codebuff
```

**Ejemplo 2: Ejecutar una tarea desde la línea de comandos**

```bash
codebuff "Agrega rate limiting a todos los endpoints de la API"
```

**Ejemplo 3: Inicializar un agente personalizado**

```bash
codebuff
# Dentro de la CLI:
/init
```
*(Esto crea la estructura `.agents/` con tipos y definiciones TypeScript).*

## Consideraciones Adicionales

*   **Suscripción:** Codebuff es un producto de pago (~$50/mes). La alternativa gratuita es Freebuff.
*   **API Key:** Requiere una clave de API de OpenRouter configurada o la autenticación mediante `codebuff auth`.
*   **SDK:** El SDK (`@codebuff/sdk`) es un paquete separado para integraciones programáticas.
*   **Código Abierto:** El proyecto es open source (Apache 2.0) en `CodebuffAI/codebuff`.

---

*Nota: Esta herramienta integra una arquitectura de agentes especializados de código abierto en el ecosistema i-Haklab. Codebuff es la base sobre la que se construye Freebuff.*
