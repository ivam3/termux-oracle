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

## QEMU + termux-x11 (termux-docker-qemu)

Flujo para ejecutar VMs con gráficos vía QEMU + termux-x11:

**1. Display SDL + VirtIO-GPU 3D (virgl)**:
```bash
termux-docker-qemu alpine x11 sdl
```
Usa `-device virtio-vga-gl` y `-display sdl,gl=on` enviando la aceleración 3D del host a la VM.

**2. Direct X11 TCP Bridge (ultra ligero)**:
```bash
termux-docker-qemu alpine x11 tcp
```
Inicia `socat` escuchando en TCP 6000 y puenteando a `${PREFIX}/tmp/.X11-unix/X0`. QEMU corre en `-nographic` eliminando el overhead de CPU de framebuffer. En Alpine se ejecuta `source /termux2alpine/x11_env.sh` (`export DISPLAY=${host_ip}:0`).

**xfwm4 necesario** — En el host Termux, xfwm4 gestiona las ventanas enviadas por Alpine o la ventana SDL.

**Resolución:** En modo SDL, se detecta dinámicamente con `xrandr` y se pasa a `-device virtio-vga-gl,xres=<ANCHO>,yres=<ALTO>`.
