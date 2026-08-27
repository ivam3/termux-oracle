# cactus

## ¿Qué es cactus?

**Cactus** es un motor de IA híbrido edge-cloud (v2.0+) que permite ejecutar modelos de lenguaje (LLMs) y de voz directamente en el dispositivo o en la nube, con una CLI unificada. Integra descarga de modelos desde HuggingFace, inferencia local con aceleración nativa, un servidor API compatible con OpenAI, y transcripción de voz (Whisper). Especialmente optimizado para ARM64 (Android/Termux).

## ¿Para qué es útil la herramienta?

- **LLMs locales en Android:** Ejecuta modelos como Llama, Mistral, Phi, Gemma directamente en el dispositivo sin conexión a internet.
- **API OpenAI-compatible:** Expone un servidor local en el puerto configurado, compatible con clientes que usan la API de OpenAI.
- **Transcripción de voz:** Convierte audio a texto usando modelos Whisper locales.
- **Gestión de modelos:** Descarga, lista y gestiona modelos en caché desde HuggingFace.
- **Autenticación HuggingFace:** Accede a modelos privados o con gating con tu token personal.

## Instalación en Termux (i-HakLab)

```bash
apt install cactus
```

Instala el motor nativo en `~/.local/share/cactus/`.

## ¿Cómo se usa? (Ejemplos básicos)

**Ejemplo 1: Autenticarse con HuggingFace**

```bash
cactus auth hf
# Solicita tu HuggingFace token
```

**Ejemplo 2: Descargar un modelo**

```bash
cactus download Cactus-Compute/needle
cactus download microsoft/Phi-3-mini-4k-instruct-gguf
```

**Ejemplo 3: Listar modelos en caché**

```bash
cactus list
```

**Ejemplo 4: Ejecutar un modelo en modo chat**

```bash
cactus run Cactus-Compute/needle
```

**Ejemplo 5: Levantar servidor API (OpenAI-compatible)**

```bash
cactus serve Cactus-Compute/needle --port 8080
# Accesible en http://localhost:8080/v1/chat/completions
```

**Ejemplo 6: Transcripción de voz**

```bash
cactus transcribe openai/whisper-base --file audio.mp3
```

**Ejemplo 7: Convertir pesos de HuggingFace**

```bash
cactus convert org/model-hf
```

## Estructura de archivos

| Ruta | Contenido |
|------|-----------|
| `~/.local/share/cactus/` | Directorio raíz de instalación |
| `~/.local/share/cactus/cactus-engine/` | Motor nativo compilado |
| `~/.local/share/cactus/weights/` | Modelos descargados |
| `~/.local/share/cactus/build.log` | Log de compilación del motor |

## Uso con otros agentes AI

Al levantar el servidor OpenAI-compatible, otros agentes en i-HakLab pueden usarlo como backend:

```bash
# Levantar cactus como servidor local
cactus serve Cactus-Compute/needle --port 8080 &

# Configurar opencode para usar el servidor local
# En ~/.config/opencode/config.json:
# { "provider": "openai", "base_url": "http://localhost:8080/v1" }
```

## Referencias

- Repositorio upstream: [cactus-compute/cactus](https://github.com/cactus-compute/cactus)
- Soporte: [t.me/Ivam3_Bot](https://t.me/Ivam3_Bot)

---
*Esta herramienta es parte del ecosistema i-HakLab para Android/Termux.*
