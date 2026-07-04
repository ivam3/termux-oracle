# Guía de Instalación de Termux 📱

Para contar con un entorno estable compatible con **i-HakLab**, es fundamental instalar la versión correcta de Termux. El error más común entre principiantes es descargar la aplicación desde Google Play Store o mezclar APKs de distintas fuentes.

## ⚠️ ¡CRÍTICO: No uses Google Play Store!
La versión de Termux en Google Play Store está **completamente obsoleta y desactualizada** debido a restricciones de nivel de API impuestas por Google en esa plataforma (las cuales impiden la ejecución de binarios dentro del directorio privado de la app en versiones modernas de Android).
* **Consecuencia de usar Google Play:** Errores de repositorios (`404 Not Found`), imposibilidad de actualizar paquetes de Python y fallos constantes al instalar dependencias de i-HakLab.

## ⚠️ REGLA DE ORO: NO mezcles fuentes de instalación
Todas las apps de Termux (app principal + plugins) deben instalarse desde la **MISMA fuente**. Mezclar APKs de distintas fuentes causa:

| Origen A | Origen B | Resultado |
|----------|----------|-----------|
| GitHub | F-Droid | Error de firma, la app se cierra al abrir |
| GitHub | Google Play | Incompatibilidad de versiones, plugins no detectados |
| F-Droid | Google Play | Conflictos de permisos, crashes aleatorios |

**Elige UNA fuente y úsala para todo:** todas las apps desde GitHub Actions, o todas desde F-Droid.

## 📥 Fuentes Oficiales de Descarga

### 🔷 Método Recomendado: GitHub Actions (build branch)
El método más recomendado para obtener la versión más reciente y estable es descargar los APKs desde las **GitHub Actions** del repositorio oficial:

1. Ve a [`https://github.com/termux/termux-app/actions`](https://github.com/termux/termux-app/actions)
2. En el selector de rama, selecciona **`build`** (no `master`)
3. Haz clic en el **workflow más reciente** (el primero de la lista)
4. Desplázate hasta **Artifacts** y descarga el APK correspondiente a tu arquitectura:
   - `app-arm64-v8a-debug.apk` — dispositivos modernos (recomendado)
   - `app-universal-debug.apk` — si no estás seguro de tu arquitectura
5. Instala el APK en tu dispositivo
6. Repite el mismo proceso para cada plugin (ver sección de plugins abajo)

> [!TIP]
> También puedes obtener los APKs desde la sección **Releases** del mismo repositorio si prefieres versiones etiquetadas, pero las Actions de la rama `build` suelen tener las correcciones más recientes.

### 🔷 Alternativa: F-Droid
Descarga el cliente de F-Droid desde [`https://f-droid.org`](https://f-droid.org) y busca "Termux". Las versiones de F-Droid son estables pero pueden estar ligeramente retrasadas respecto a las de GitHub Actions.

### ❌ No recomendado: Google Play Store
La versión de Google Play Store está obsoleta y no funcionará correctamente.

## 🧩 Plugins de Termux (misma fuente siempre)

Termux cuenta con aplicaciones complementarias que extienden sus capacidades. **Debes instalar cada plugin desde la misma fuente que elegiste para la app principal:**

| Plugin | Repositorio | Package apt | Propósito |
|--------|-------------|-------------|-----------|
| **Termux:API** | [`termux/termux-api`](https://github.com/termux/termux-api) | `termux-api` | Acceso a sensores, cámara, clipboard, TTS, notificaciones, ubicación |
| **Termux:X11** | [`termux/termux-x11`](https://github.com/termux/termux-x11) | `termux-x11-nightly` | Servidor gráfico X11 para entornos de escritorio |
| **Termux:Float** | [`termux/termux-float`](https://github.com/termux/termux-float) | — | Ventana flotante superpuesta a otras apps |
| **Termux:Styling** | [`termux/termux-styling`](https://github.com/termux/termux-styling) | — | Temas y fuentes para la terminal |

Cada plugin se descarga desde **Actions → rama `build`** del repositorio correspondiente, exactamente igual que la app principal.

## 📚 Tutorial paso a paso

Para una guía visual detallada paso a paso de todo el proceso de instalación (incluyendo la descarga desde GitHub Actions, instalación de plugins y configuración inicial), ejecuta:

```bash
i-haklab show tutorials
```

Este comando muestra el listado completo de tutoriales disponibles, incluyendo **"termux tips cap 1.1"** que cubre la instalación desde GitHub en detalle.

## ⚙️ Requerimientos Mínimos
* **Sistema Operativo:** Android 7.0 (Nougat) o superior.
* **Almacenamiento:** Al menos 2 GB de espacio libre (el entorno base de Linux y el arsenal de herramientas de auditoría se expanden considerablemente).
* **Conexión a Internet:** Estable, preferiblemente Wi-Fi para las fases de instalación e inicialización de repositorios.
