# Acceso al Almacenamiento en Termux 💾📱

Por defecto, Termux opera en un espacio de almacenamiento aislado (directorio privado de la aplicación) al que otras aplicaciones de Android no pueden acceder directamente. Para poder leer o escribir archivos en la memoria interna del celular (como descargas, fotos o documentos), es necesario configurar el acceso al almacenamiento compartido.

---

## 🔐 1. El Comando `termux-setup-storage`

Para conceder permisos de almacenamiento a Termux y enlazar los directorios principales del dispositivo, ejecuta el siguiente comando:

```bash
termux-setup-storage
```

### ¿Qué sucede al ejecutarlo?
1. Android mostrará una ventana emergente solicitando que permitas a Termux acceder a las fotos, el contenido multimedia y los archivos de tu dispositivo. Debes seleccionar **Permitir**.
2. Termux creará un nuevo directorio en tu carpeta de inicio llamado `~/storage`.
3. Dentro de `~/storage`, se crearán enlaces simbólicos (accesos directos) a los directorios comunes del sistema.

---

## 📁 2. Estructura de Enlaces en `~/storage`

Una vez concedidos los permisos, la estructura dentro de tu carpeta personal será la siguiente:

* **`~/storage/shared`**: Enlace directo a la raíz de la memoria interna compartida (`/sdcard` o `/storage/emulated/0`).
* **`~/storage/downloads`**: Acceso directo a tu carpeta de descargas (`/sdcard/Download`).
* **`~/storage/pictures`**: Acceso directo a `/sdcard/Pictures`.
* **`~/storage/dcim`**: Acceso directo a la carpeta de la cámara (`/sdcard/DCIM`).
* **`~/storage/movies`**: Acceso directo a `/sdcard/Movies`.
* **`~/storage/external-1`**: Enlace al almacenamiento privado de Termux en una tarjeta SD externa (si está insertada).

---

## ⚖️ 3. Almacenamiento Privado vs. Compartido

Es crucial entender dónde guardar los archivos según su uso para evitar pérdidas de información o problemas de rendimiento:

| Característica | Almacenamiento Privado de Termux (`$HOME`) | Almacenamiento Compartido (`/sdcard`) |
| :--- | :--- | :--- |
| **Ruta en el sistema** | `/data/data/com.termux/files/home` | `/sdcard` o `/storage/emulated/0` |
| **Acceso desde Android**| Requiere Root o aplicaciones especiales. | Accesible para cualquier gestor de archivos. |
| **Soporte de permisos** | Soporta enlaces simbólicos, permisos de ejecución (`chmod +x`), `git clone` y compilación. | **No soporta permisos de ejecución (`noexec`)** ni enlaces simbólicos debido al sistema de archivos virtual de Android. |
| **Desinstalación** | **¡Al desinstalar Termux se borra todo este contenido!** | Los archivos permanecen intactos tras desinstalar Termux. |

> [!CRITICAL]
> **NUNCA ejecutes `git clone` o intentes compilar herramientas directamente dentro de `/sdcard` o `~/storage/shared`**. Debido a restricciones de seguridad de Android y al formato FAT32/exFAT simulado, no se permiten permisos de ejecución en esa zona, lo que provocará errores de `Permission Denied` al intentar correr scripts o binarios compilados. Guarda siempre tus scripts de desarrollo en tu `$HOME` local.

---

## ⚠️ 4. Solución a Problemas Frecuentes

### Error: "Permission Denied" al acceder a `~/storage`
Si ejecutas comandos y recibes errores de permisos incluso después de haber corrido `termux-setup-storage`, prueba lo siguiente:
1. Dirígete a los **Ajustes de Android** > **Aplicaciones** > **Termux**.
2. Entra en la sección de **Permisos**.
3. Revoca el permiso de Almacenamiento y vuelve a concederlo manualmente seleccionando "Permitir acceso a todos los archivos" (en Android 11 o superior).
4. En Termux, fuerza la recarga ejecutando:
   ```bash
   termux-setup-storage
   ```

### Acceso a Tarjetas SD Externas o Unidades OTG USB
En versiones de Android 10 y superiores, Google restringe fuertemente el acceso de escritura directa a unidades de almacenamiento externo extraíbles por motivos de seguridad (Scoped Storage).
* Termux solo tiene acceso de **lectura** en la raíz de tarjetas SD externas.
* El único directorio donde Termux tiene permisos de **escritura** completa en la tarjeta externa es en su carpeta dedicada: 
  `/storage/XXXX-XXXX/Android/data/com.termux/files/` (donde `XXXX-XXXX` es el identificador de tu tarjeta SD).
