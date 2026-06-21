# Evasión de Limitaciones en Android sin Acceso Root 📱🚫🔓

Una de las principales barreras al usar Termux para desarrollo avanzado, pentesting y administración de sistemas son las restricciones de seguridad impuestas por el sistema operativo Android en espacio de usuario. Al no ser **ROOT**, el sandbox de Android restringe el acceso a sockets crudos, puertos bajos (<1024), el kernel del sistema operativo, el acceso a archivos de sistema (como `/etc/hosts`) y llamadas del sistema críticas (como enlaces duros / `hardlink` bloqueados por SELinux).

Para superar estas limitaciones estructurales, el ecosistema **i-HakLab** implementa tres estrategias clave de virtualización y emulación en espacio de usuario.

---

## 🗺️ Matriz de Soluciones sin Root

| Limitación de Android | Herramienta de Evasión | Tipo de Solución | Impacto / Caso de Uso |
| :--- | :--- | :--- | :--- |
| Bloqueo de escritura en `/etc/hosts` del dispositivo. | **`proot-distro`** | Emulación de llamadas de sistema (`ptrace`). | Redirección de DNS locales, auditoría web y testing de dominios en Firefox. |
| Incompatibilidad de Docker (falta de Kernel Namespaces y cgroups). | **`udocker`** | Ejecución de contenedores en espacio de usuario. | Despliegue de imágenes Docker preconstruidas (databases, APIs) sin daemon. |
| Restricciones estrictas de SELinux y falta de Kernel Linux propio. | **QEMU (`termux-docker-qemu`)** | Virtualización completa de Hardware (Emulador). | Ejecución de Docker nativo dentro de un Linux Alpine virtualizado con kernel propio. |

---

## 1. Emulación de Entorno con `proot-distro`

**PRoot** es la solución estándar para ejecutar distribuciones de Linux completas (Debian, Ubuntu, Alpine, etc.) dentro del espacio de usuario de Termux. Utiliza la llamada del sistema `ptrace` para interceptar las llamadas al sistema del binario virtualizado y traducir los paths de Termux a los paths estándar de Linux (ej. `/lib`, `/usr/bin`).

### El Caso del bypass de `/etc/hosts` (Detección de DNS/Dominios)
En Android sin root, es imposible editar el archivo `/etc/hosts` del sistema global para apuntar un dominio a una IP local. Esto impide realizar auditorías web locales con dominios personalizados.

**La Solución:**
1. Instalar y levantar una distribución Linux dentro de Termux usando `proot-distro`:
   ```bash
   pkg install proot-distro
   proot-distro install debian
   proot-distro login debian
   ```
2. Dentro de la sesión de Debian en PRoot, edita el archivo virtualizado `/etc/hosts`:
   ```bash
   echo "127.0.0.1  mi-objetivo.local" >> /etc/hosts
   ```
3. Ejecuta herramientas web o navegadores gráficos (como Firefox a través de X11) **dentro** del mismo entorno de PRoot. Firefox resolverá `mi-objetivo.local` apuntando localmente, puenteando por completo la restricción de red de Android.

---

## 2. Contenedores en Espacio de Usuario con `udocker`

El daemon de Docker tradicional requiere acceso a nivel de Kernel (namespaces, cgroups, soporte de red bridge y sistemas de archivos copy-on-write). En dispositivos Android sin root, arrancar el daemon `dockerd` es imposible.

### ¿Qué es `udocker`?
`udocker` es un framework de espacio de usuario desarrollado para ejecutar aplicaciones Docker en sistemas donde no se puede tener privilegios de root (como servidores HPC o Android).

* **Funcionamiento:** Descarga las imágenes directamente desde Docker Hub, extrae las capas del contenedor en directorios de usuario, y ejecuta los comandos utilizando motores de ejecución en espacio de usuario (comúnmente PRoot o Fakechroot).
* **Uso en Termux:** Permite descargar e iniciar bases de datos (MySQL, PostgreSQL), servidores web (Nginx) y herramientas específicas empaquetadas en Docker directamente desde la terminal de Termux.

---

## 3. Virtualización Completa con QEMU: `termux-docker-qemu`

Cuando las soluciones basadas en PRoot o `udocker` fallan (debido a que algunas herramientas requieren syscalls de red avanzadas o soporte real de cgroups del kernel), la **virtualización de hardware** es la mejor y más robusta opción.

### El Paquete `termux-docker-qemu`
Este paquete, integrado en las distribuciones de **termux-packages** de Ivam3, automatiza el despliegue de una máquina virtual ligera que ejecuta **Alpine Linux** emulando la arquitectura del procesador a través de QEMU.

* **Ventajas de la Máquina Virtual:**
  * **Kernel Propio:** La VM corre un Kernel de Linux estándar compilado para virtualización, el cual cuenta con todos los namespaces, cgroups y módulos de red activos.
  * **Docker Nativo Funcionando:** Al contar con un kernel real, es posible ejecutar el motor Docker nativo (`apk add docker`) y levantar contenedores reales con soporte de red sin las restricciones del kernel de Android.
  * **Aislamiento Total:** Evita cualquier interferencia con SELinux de Android.
* **Flujo de Uso:**
  * Al instalar `termux-docker-qemu`, se preconfigura la imagen de Alpine Linux optimizada para arrancar en segundos.
  * El script de inicio lanza QEMU en segundo plano y expone un puerto SSH local (ej. `localhost:2222`) para interactuar con la VM.
  * Desde Termux, te conectas a la VM Alpine mediante:
    ```bash
    ssh root@localhost -p 2222
    ```
  * Una vez dentro, tienes un entorno Linux completo con privilegios root absolutos e independientes sobre el sistema virtualizado.
