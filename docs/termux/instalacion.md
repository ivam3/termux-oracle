# Guía de Instalación de Termux 📱

Para contar con un entorno estable compatible con **i-HakLab**, es fundamental instalar la versión correcta de Termux. El error más común entre principiantes es descargar la aplicación desde Google Play Store.

## ⚠️ ¡CRÍTICO: No uses Google Play Store!
La versión de Termux en Google Play Store está **completamente obsoleta y desactualizada** debido a restricciones de nivel de API impuestas por Google en esa plataforma (las cuales impiden la ejecución de binarios dentro del directorio privado de la app en versiones modernas de Android).
* **Consecuencia de usar Google Play:** Errores de repositorios (`404 Not Found`), imposibilidad de actualizar paquetes de Python y fallos constantes al instalar dependencias de i-HakLab.

## 📥 Fuentes Oficiales de Descarga
Para instalar la última versión funcional e independiente:
1. **F-Droid:** Descarga el cliente de F-Droid o el APK directo desde el sitio web oficial de F-Droid.
2. **GitHub Releases:** Dirígete al repositorio oficial de `termux/termux-app` en GitHub y descarga el APK correspondiente a la arquitectura de tu procesador (comúnmente `arm64-v8a` para dispositivos modernos).

## ⚙️ Requerimientos Mínimos
* **Sistema Operativo:** Android 7.0 (Nougat) o superior.
* **Almacenamiento:** Al menos 2 GB de espacio libre (el entorno base de Linux y el arsenal de herramientas de auditoría se expanden considerablemente).
* **Conexión a Internet:** Estable, preferiblemente Wi-Fi para las fases de instalación e inicialización de repositorios.
