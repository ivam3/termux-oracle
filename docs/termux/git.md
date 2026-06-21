# Control de Versiones con Git en Termux 🚀🐙

**Git** es la herramienta estándar para el control de versiones de código y es crucial en Termux para clonar herramientas de ciberseguridad, descargar scripts de automatización y gestionar tus propios proyectos de desarrollo.

---

## 🛠️ 1. Instalación y Configuración Inicial

Para comenzar a usar Git, primero debes instalar el paquete correspondiente desde los repositorios oficiales de Termux.

### Instalación:
```bash
pkg update
pkg install git -y
```

### Configuración de Identidad:
Antes de realizar tu primer commit, es necesario configurar tu nombre y correo electrónico. Git utiliza estos datos para asociar la autoría de los cambios.
```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu-correo@example.com"
```

> [!TIP]
> Puedes verificar que la configuración se aplicó correctamente listando los valores guardados:
> ```bash
> git config --list
> ```

---

## 🔑 2. Autenticación con GitHub y GitLab

Desde agosto de 2021, GitHub ya no acepta contraseñas de cuentas para autenticar operaciones de Git. Debes utilizar un **Token de Acceso Personal (PAT)** o una **Llave SSH**.

### Método A: Usar una Llave SSH (Recomendado y más seguro)
1. Genera una llave SSH en Termux si aún no tienes una:
   ```bash
   ssh-keygen -t ed25519 -C "tu-correo@example.com"
   ```
   *(Presiona Enter para guardar en la ruta por defecto y dejarla sin contraseña).*
2. Muestra el contenido de la llave pública generada y cópialo:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```
3. Ve a tu cuenta de GitHub > **Settings** > **SSH and GPG keys** > **New SSH Key**. Ponle un título (ej: "Termux Celular") y pega la llave copiada.
4. Para probar la conexión, ejecuta:
   ```bash
   ssh -T git@github.com
   ```
   *(Deberías ver un mensaje de éxito con tu nombre de usuario de GitHub).*

### Método B: Guardar Credenciales (PAT)
Si prefieres conectarte por HTTPS y usar un Token de Acceso Personal de GitHub, configura a Git para que recuerde tus credenciales y no tengas que escribirlas en cada `push`:
```bash
git config --global credential.helper store
```
La primera vez que hagas `git push`, te pedirá tu usuario de GitHub y tu contraseña (deberás pegar tu Token PAT en lugar de tu contraseña real). Git guardará estos datos de forma persistente y segura en un archivo local.

---

## 📂 3. Comandos Esenciales de Flujo de Trabajo

Aquí tienes la lista de comandos que utilizarás a diario en Termux para gestionar tus repositorios:

* **`git clone <URL>`**: Descarga un repositorio remoto a tu carpeta local en Termux.
  * *Ejemplo*: `git clone git@github.com:usuario/proyecto.git`
* **`git init`**: Inicializa un repositorio Git vacío en la carpeta donde te encuentres parado.
* **`git status`**: Muestra el estado actual del directorio de trabajo (archivos modificados, agregados o sin seguimiento).
* **`git add <archivo>`**: Añade archivos específicos al área de preparación (*staging area*). Usa `git add .` para añadir todos los cambios.
* **`git commit -m "Mensaje explicativo"`**: Guarda los cambios preparados en el historial local del repositorio.
* **`git push origin main`**: Sube tus commits locales al repositorio remoto (en la rama `main`).
* **`git pull`**: Descarga e integra los últimos cambios del repositorio remoto al local.

---

## ⚠️ 4. Problemas Comunes en Termux

### Error: "Permission Denied" al clonar en la tarjeta SD (`/sdcard`)
Como se detalla en la guía de [Almacenamiento](./almacenamiento.md), la memoria interna compartida de Android no admite permisos de Linux ni enlaces simbólicos.
* **Solución**: Clona siempre tus repositorios dentro del almacenamiento privado de Termux (`$HOME` o `~`). Nunca ejecutes `git clone` dentro de `/sdcard/` o `~/storage/shared/`.

### Error: SSL Certificate Problem / Expired Certificate
En dispositivos Android antiguos o instalaciones de Termux desactualizadas, a veces falla la validación SSL al conectarse a GitHub.
* **Solución**: Instala o actualiza el paquete de certificados del sistema ejecutando:
  ```bash
  pkg install ca-certificates -y
  ```
