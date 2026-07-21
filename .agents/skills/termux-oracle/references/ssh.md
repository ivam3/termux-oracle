# Servidor SSH en Termux

## Instalación y configuración básica
```bash
pkg install openssh -y
passwd                      # establecer contraseña para el usuario Termux
sshd                        # iniciar servidor (puerto 8022)
```

**Importante:** Termux corre SSH en puerto `8022` (no `22`), porque Android no permite puertos <1024 sin root.

## Conexión desde PC
```bash
# Obtener IP del celular
ifconfig                    # buscar wlan0

# Conectar
ssh <usuario>@<IP> -p 8022
```
Obtener usuario con: `whoami` (ej: `u0_a254`).

## Conexión con llaves SSH (sin contraseña)
```bash
# En la PC: generar llave
ssh-keygen -t rsa -b 4096

# Copiar llave a Termux
ssh-copy-id -p 8022 <usuario>@<IP>

# O manualmente: copiar ~/.ssh/id_rsa.pub de la PC
# a ~/.ssh/authorized_keys en Termux
```

## Administración
```bash
sshd                        # iniciar servidor
pkill sshd                  # detener servidor
netstat -tuln | grep 8022   # verificar si está corriendo
```
Para inicio automático, agregar `sshd` a `~/.bashrc`.
