# huggingface (huggingface-cli)

## ¿Qué es huggingface-cli?

**huggingface-cli** es la CLI oficial de [HuggingFace Hub](https://huggingface.co), la plataforma más grande del mundo de modelos de IA open-source. Permite descargar modelos, datasets y espacios directamente desde la terminal, autenticarse con tokens, y subir archivos a la plataforma.

En i-HakLab se usa principalmente para gestionar modelos locales de LLMs, embeddings y Whisper que alimentan herramientas como `cactus`, `ollama` y agentes de codificación.

## ¿Para qué es útil la herramienta?

- **Descarga de modelos LLM:** Obtén modelos Llama, Mistral, Phi, Gemma, Whisper, etc. directamente a Termux.
- **Autenticación con token HF:** Accede a modelos con acceso restringido (gated models como Llama 3).
- **Publicación de modelos:** Sube tus propios modelos o fine-tunes a HuggingFace.
- **Integración con cactus/ollama:** Descarga los weights que otros motores locales necesitan.
- **Uso programático (Python):** Importa `huggingface_hub` en scripts Python para automatizar descargas.

## Instalación en Termux (i-HakLab)

```bash
apt install huggingface
```

> [!NOTE]
> El paquete configura automáticamente `HF_HUB_DISABLE_XET=1` en `$PREFIX/etc/profile.d/huggingface.sh` para compatibilidad con Termux (el acelerador `hf-xet` no está disponible para Android).

## ¿Cómo se usa? (Ejemplos básicos)

**Ejemplo 1: Autenticarse con token de HuggingFace**

```bash
huggingface-cli login
# Solicita tu token desde https://huggingface.co/settings/tokens
```

**Ejemplo 2: Ver usuario autenticado**

```bash
huggingface-cli whoami
```

**Ejemplo 3: Descargar un modelo**

```bash
huggingface-cli download microsoft/Phi-3-mini-4k-instruct
huggingface-cli download meta-llama/Llama-3.2-1B-Instruct
```

**Ejemplo 4: Descargar solo un archivo específico**

```bash
huggingface-cli download Qwen/Qwen2.5-0.5B-Instruct \
  --include "*.gguf" \
  --local-dir ~/models/qwen
```

**Ejemplo 5: Subir archivos a HuggingFace**

```bash
huggingface-cli upload mi-usuario/mi-modelo ./ruta/al/modelo
```

**Ejemplo 6: Uso desde Python**

```python
from huggingface_hub import snapshot_download

snapshot_download(
    repo_id="microsoft/Phi-3-mini-4k-instruct",
    local_dir="~/models/phi3"
)
```

## Configuración en Termux

| Variable | Valor | Razón |
|----------|-------|-------|
| `HF_HUB_DISABLE_XET` | `1` | Deshabilita hf-xet (no disponible en Android) |
| `HF_HOME` | `~/.cache/huggingface` | Directorio de caché por defecto |

## Integración con otras herramientas de i-HakLab

```bash
# Descargar modelo para cactus
huggingface-cli download Cactus-Compute/needle --local-dir ~/.local/share/cactus/weights/

# Descargar modelo Whisper para transcripción
huggingface-cli download openai/whisper-base --local-dir ~/models/whisper/
```

## Referencias

- Documentación oficial: [huggingface.co/docs/huggingface_hub](https://huggingface.co/docs/huggingface_hub)
- Repositorio: [huggingface/huggingface_hub](https://github.com/huggingface/huggingface_hub)
- Tokens: [huggingface.co/settings/tokens](https://huggingface.co/settings/tokens)

---
*Esta herramienta es parte del ecosistema i-HakLab para Android/Termux.*
