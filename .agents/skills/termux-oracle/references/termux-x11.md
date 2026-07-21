# Interfaz Gráfica: Termux-X11 y XFCE

Termux-X11 es un servidor X11 nativo para Android con renderizado GPU acelerado, superior a VNC en latencia y framerate.

## Instalación
```bash
pkg install termux-x11 termux-desktop-xfce
```

## Flujo de trabajo
1. Abrir la app **Termux-X11** en Android (espera conexión)
2. En Termux CLI ejecutar:
   ```bash
   termux-x11 :1 -xstartup "dbus-launch --exit-with-session xfce4-session" &
   am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity
   ```

## Optimización
- **Resolución dinámica:** Ajustar escala en la app Termux-X11 de Android
- **Aceleración GPU (VirGL):**
  ```bash
  GALLIUM_DRIVER=virpipe virgl_test_server_android &
  DISPLAY=:1 gallery_app
  ```
