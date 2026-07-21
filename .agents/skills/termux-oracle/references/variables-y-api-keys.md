# Variables de Entorno y API Keys

## Archivo `envvariables` (`~/.local/etc/i-Haklab/envvariables`)
Define parámetros cargados en cada inicio de sesión:

| Variable | Valor | Propósito |
|----------|-------|-----------|
| `PATH` | `~/.local/bin:$PREFIX/bin:$HOME/go/bin` | Wrappers primero |
| `DISPLAY` | `:0` | Display X11 por defecto |
| `GYP_DEFINES` | `android_ndk_path=''` | Omite NDK check en npm |
| `JAVA_HOME` | `$PREFIX/opt/openjdk` | JDK para apktool |
| `ANDROID_NDK_HOME` | `$PREFIX` | Cabeceras de desarrollo |
| `ANDROID_API_LEVEL` | `24` | API level para compilación |
| `CFLAGS` | `-Wno-incompatible-function-pointer-types` | Silencia warnings estrictos |
| `CC`/`CXX` | `clang`/`clang++` | Compiladores por defecto |
| `EDITOR`/`VISUAL` | `nvim` | Editor por defecto |

### Aliases del archivo
| Alias | Comando |
|-------|---------|
| `la` | `ls -a` |
| `ll` | `ls -l` |
| `du` | `du -hP` |
| `df` | `duf` |
| `bat` | `bat -f --theme 'Visual Studio Dark+'` |
| `postgresql` | `pg_ctl -D $PREFIX/var/lib/postgresql` |

## Gestión de API Keys: `i-Haklab setapikey`
Menú interactivo para configurar claves de servicios externos.

| Plataforma | Obtención |
|------------|-----------|
| OpenAI (chatGPT) | `https://platform.openai.com/account/api-keys` |
| Anthropic (claude) | `https://console.anthropic.com` |
| DeepSeek | `https://api-docs.deepseek.com/` |
| Google (gemini) | `https://aistudio.google.com` |
| Mistral AI | `https://console.mistral.ai` |
| Numverify (phonescan) | `https://numverify.com/dashboard` |

Las claves se almacenan en `~/.local/etc/i-HakLab/variables` como `APIKEY_<plataforma>`.

**No editar `variables` manualmente** — usar siempre `i-Haklab setapikey`.
