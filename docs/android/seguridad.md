# Fundamentos de Seguridad en Android 🛡️🤖

Para interactuar de forma técnica con Android y herramientas avanzadas en Termux, es indispensable comprender la arquitectura de seguridad subyacente del sistema operativo. Android está construido sobre un kernel Linux, pero modifica de manera radical el modelo de seguridad clásico de escritorio para proteger los datos de los usuarios y aislar las aplicaciones.

---

## 📦 1. El Sandbox de Aplicaciones (Application Sandboxing)

En un sistema Linux de escritorio tradicional, todas las aplicaciones que ejecuta un usuario comparten los mismos privilegios del usuario. Si ejecutas un programa malicioso, este puede leer todos tus archivos personales.

Android resuelve esto implementando el **Sandbox de Aplicaciones**:
* **Usuarios Únicos**: Cada aplicación instalada en Android recibe un Identificador de Usuario de Linux único (UID) y corre en su propio proceso independiente.
* **Aislamiento**: Ninguna aplicación puede acceder a los archivos de otra aplicación ni interactuar con su memoria sin autorización explícita. Por ejemplo, Termux corre bajo un UID propio (como `u0_a254`) y no puede leer la base de datos de WhatsApp u otras aplicaciones a menos que tenga permisos de Root.

---

## 🔐 2. El Sistema de Permisos de Android

Para romper el aislamiento del Sandbox de forma segura, Android utiliza un modelo de permisos:

* **Permisos en Tiempo de Instalación**: Se conceden automáticamente al instalar la aplicación (ej. acceso a internet).
* **Permisos en Tiempo de Ejecución (Runtime Permissions)**: Se solicitan al usuario mientras usa la app (ej. acceso a la cámara, contactos o almacenamiento).
* **Permisos Especiales / Peligrosos**:
  * **Acceso a Accesibilidad**: Permite a una app leer el contenido de la pantalla y simular toques. Es el vector más común explotado por troyanos bancarios.
  * **Superposición sobre otras Apps (Draw over other apps)**: Permite dibujar ventanas flotantes sobre otras aplicaciones (potencial vector de ataques de phishing mediante pantallas falsas).

---

## 💾 3. Seguridad de Almacenamiento: Scoped Storage

Introducido a partir de Android 10 y consolidado en Android 11+, el **Scoped Storage (Almacenamiento Aislado)** restringe drásticamente la forma en que las aplicaciones acceden a los archivos compartidos.

* **Antes de Android 10**: Conceder el permiso de almacenamiento permitía a una app leer y escribir en absolutamente cualquier directorio de la memoria interna (`/sdcard`).
* **Con Scoped Storage**:
  * Cada aplicación tiene acceso ilimitado a su directorio de almacenamiento privado (en el caso de Termux: `/data/data/com.termux/files/home`).
  * Para acceder a la carpeta compartida (`/sdcard`), las apps deben pasar por APIs del sistema que limitan qué tipos de archivos pueden ver.
  * Las carpetas del sistema `/sdcard/Android/data` y `/sdcard/Android/obb` están completamente bloqueadas para aplicaciones de terceros para evitar que lean datos sensibles de otras aplicaciones.

---

## 🔓 4. Root vs. No-Root: Implicaciones de Seguridad

Obtener permisos de **Root** (superusuario) en Android significa romper las barreras de seguridad y el Sandbox del sistema para tener control absoluto.

### Implicaciones de Seguridad al obtener Root:

| Aspecto | Sin Root (Entorno Estándar) | Con Root (Magisk / KernelSU) |
| :--- | :--- | :--- |
| **Control del Sistema** | Limitado a los permisos estándar de Android. | Control absoluto. Puedes modificar archivos de sistema y el kernel. |
| **Sandbox de Apps** | Totalmente activo. Las apps están aisladas. | Puede ser vulnerado. Si concedes root a una app maliciosa, esta puede robar datos de cualquier app. |
| **Seguridad Bancaria**| Las aplicaciones financieras funcionan normalmente. | Frecuentemente detectan el Root mediante *Play Integrity* y se bloquean por seguridad. |
| **Termux** | No puede ejecutar herramientas de bajo nivel de red (ej. descargas de paquetes de red Wi-Fi, inyección de tráfico raw) ni modificar particiones del sistema. | Puede ejecutar herramientas de auditoría avanzada, montar particiones del sistema y extraer bases de datos locales. |

---

## 🛡️ 5. Protecciones del Sistema Modernas

Android incorpora tecnologías de endurecimiento activas a nivel de hardware y firmware:

1. **SEAndroid / SELinux (Security-Enhanced Linux para Android)**:
   * Actúa como una capa obligatoria de control de acceso por encima del sistema de permisos clásicos de Linux. Define políticas estrictas sobre qué demonios, procesos y apps pueden comunicarse entre sí, incluso si un proceso corre con permisos de root (UID 0).
2. **Android Verified Boot (AVB)**:
   * Asegura que todo el código ejecutado durante el arranque proviene de una fuente confiable y no ha sido modificado. Si modificas la partición de sistema sin firmarla o sin abrir el bootloader, dm-verity impedirá que el teléfono encienda.
3. **Cifrado basado en Archivos (File-Based Encryption - FBE)**:
   * Cada archivo del dispositivo se cifra de forma individual con llaves únicas asociadas a las credenciales de bloqueo de tu pantalla. Los datos son ilegibles hasta que desbloqueas tu celular por primera vez tras encenderlo.
