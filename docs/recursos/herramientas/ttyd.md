# ttyd

## ¿Qué es ttyd?

**ttyd** es una herramienta que comparte la terminal de Termux directamente en el navegador web a través de WebSockets. Convierte cualquier sesión de terminal en una interfaz web interactiva accesible desde cualquier dispositivo en la misma red (o remotamente con túneles).

## ¿Para qué es útil la herramienta?

- **Terminal web:** Accede a Termux desde el navegador del PC, tablet u otro teléfono sin apps adicionales.
- **Colaboración remota:** Comparte tu sesión de terminal en tiempo real con otros usuarios.
- **Integración con túneles:** Combínalo con `ngrok`, `cloudflared` o `localtunnel` para acceso remoto seguro desde cualquier lugar.
- **Entorno gráfico alternativo:** Útil cuando no se puede usar SSH pero sí hay acceso web.
- **Demos y tutoriales:** Muestra comandos en vivo desde el navegador.

## Instalación en Termux (i-HakLab)

```bash
apt install ttyd
# o desde los repos oficiales de Termux:
pkg install ttyd
```

## ¿Cómo se usa? (Ejemplos básicos)

**Ejemplo 1: Compartir bash en el puerto 7681 (por defecto)**

```bash
ttyd bash
# Acceder desde: http://<IP-del-dispositivo>:7681
```

**Ejemplo 2: Especificar puerto personalizado**

```bash
ttyd -p 8080 bash
```

**Ejemplo 3: Compartir fish shell**

```bash
ttyd fish
```

**Ejemplo 4: Con autenticación básica**

```bash
ttyd -c usuario:contraseña bash
```

**Ejemplo 5: Solo lectura (para demos)**

```bash
ttyd -R bash
```

**Ejemplo 6: Exponer remotamente con ngrok**

```bash
# Terminal 1: levantar ttyd
ttyd -p 7681 bash &

# Terminal 2: exponer con ngrok
ngrok http 7681
```

**Ejemplo 7: Exponer con cloudflared**

```bash
ttyd bash &
cloudflared tunnel --url http://localhost:7681
```

## Obtener la IP para acceder

```bash
# Ver IP local
LOCALHOST
# o
ip a | grep "inet " | grep -v 127
```

Accede desde el navegador: `http://<tu-IP>:7681`

## Consideraciones en Android/Termux

- Requiere que el dispositivo y el cliente estén en la misma red WiFi (para acceso local).
- Para acceso externo usar túneles (`ngrok`, `cloudflared`, `localtunnel`).
- La sesión de terminal se mantiene activa mientras ttyd esté corriendo.
- Compatible con `tmux` para sesiones persistentes:

```bash
tmux new-session -d -s main
ttyd tmux attach-session -t main
```

## Referencias

- Repositorio: [tsl0922/ttyd](https://github.com/tsl0922/ttyd)
- Documentación: [github.com/tsl0922/ttyd/wiki](https://github.com/tsl0922/ttyd/wiki)

---
*Esta herramienta es parte del ecosistema i-HakLab para Android/Termux.*
