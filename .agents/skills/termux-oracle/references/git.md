# Git en Termux

## Instalación y configuración
```bash
pkg install git -y
git config --global user.name "Tu Nombre"
git config --global user.email "tu-correo@example.com"
```

## Autenticación con GitHub/GitLab

### Método SSH (recomendado)
```bash
ssh-keygen -t ed25519 -C "tu-correo@example.com"
cat ~/.ssh/id_ed25519.pub
```
Agregar la llave en GitHub → Settings → SSH and GPG keys → New SSH Key.
```bash
ssh -T git@github.com
```

### Método HTTPS con Token (PAT)
```bash
git config --global credential.helper store
```
En el primer push, usar Token PAT como contraseña (no la password de la cuenta).

## Comandos esenciales
| Comando | Descripción |
|---------|-------------|
| `git clone <URL>` | Descargar repositorio |
| `git init` | Inicializar repositorio |
| `git status` | Estado del working tree |
| `git add <archivo>` | Agregar al staging |
| `git commit -m "msg"` | Committear cambios |
| `git push origin main` | Subir commits |
| `git pull` | Bajar cambios remotos |

## Problemas comunes
| Error | Solución |
|-------|----------|
| `Permission denied` al clonar en `/sdcard` | Clonar solo en `$HOME` (noexec en SD) |
| `SSL Certificate Problem` | `pkg install ca-certificates -y` |
