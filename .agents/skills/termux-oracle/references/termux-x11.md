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

## Audio: PulseAudio en entornos gráficos

**Síntoma:** La GUI corre pero no hay sonido, o el sonido sale por un sink `auto_null` (no llega al altavoz del Android).

**Causa raíz:** PulseAudio autospawnea un segundo daemon. Cada daemon tiene su propio sink por defecto:
- El primero (el bueno) usa `OpenSL_ES_sink` (altavoz real del dispositivo).
- Un segundo daemon autospawnado crea el sink virtual `auto_null` (silencio).

Además, `pulseaudio --start --load="module-native-protocol-tcp ..."` solo carga el módulo TCP si el daemon lo levanta; si ya hay otro daemon corriendo, `--load` se ignora y las apps remotas (proot/QEMU con `PULSE_SERVER=127.0.0.1`) quedan sin audio.

**Fix determinista** (aplicado en `~/.local/libexec/i-Haklab/Xwayland`, `packages/termux-desktop-xfce/desktop` y `~/.local/libexec/i-Haklab/pd`):
```bash
# 1. Matar cualquier daemon previo y limpiar sockets/symlinks
killall pulseaudio 2>/dev/null; sleep 1
rm -rf ${TMPDIR}/pulse ${TMPDIR}/pulse-* 2>/dev/null
rm -f ${HOME}/.config/pulse/*-runtime 2>/dev/null

# 2. Runtime fijo (evita rutas default duplicadas)
mkdir -p ${TMPDIR}/pulse
export PULSE_RUNTIME_PATH=${TMPDIR}/pulse

# 3. Un único daemon
pulseaudio --start --exit-idle-time=-1 2>/dev/null
for _ in $(seq 1 10); do
    [[ -S ${PULSE_RUNTIME_PATH}/native ]] && break
    sleep 1
done

# 4. Guard: si el daemon quedó con sink auto_null, reiniciar
sink=$(PULSE_SERVER=unix:${PULSE_RUNTIME_PATH}/native pactl info 2>/dev/null | sed -n 's/^Default Sink: //p')
[[ "$sink" == "auto_null" ]] && {
    killall pulseaudio 2>/dev/null; sleep 1
    pulseaudio --start --exit-idle-time=-1 2>/dev/null
    for _ in $(seq 1 10); do [[ -S ${PULSE_RUNTIME_PATH}/native ]] && break; sleep 1; done
}

# 5. Cargar TCP contra el socket del daemon bueno y exportar para clientes remotos
PULSE_SERVER=unix:${PULSE_RUNTIME_PATH}/native pacmd load-module \
    module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null
export PULSE_SERVER=tcp:127.0.0.1:4713
```

**Verificación (sin matar la sesión):**
```bash
[[ -S ${TMPDIR}/pulse/native ]] && echo "socket OK"
PULSE_SERVER=unix:${TMPDIR}/pulse/native pactl info | grep "Default Sink"
# → debe decir OpenSL_ES_sink, NUNCA auto_null
# Prueba del TCP real (clientes remotos):
PULSE_SERVER=tcp:127.0.0.1:4713 pactl info
PULSE_SERVER=tcp:127.0.0.1:4713 paplay <archivo.wav>   # debe salir exit 0
```

**Gotchas:**
- `ss -tlnp`/`netstat` NO muestran el puerto 4713 en Termux (Android bloquea la visibilidad de sockets); probar el TCP con `PULSE_SERVER=tcp:127.0.0.1:4713 pactl info`.
- `paplay` usa el sink por defecto local; para probar el TCP hay que exportar `PULSE_SERVER` como arriba.
- `mpv` usa `opensles` por defecto en Termux (no PulseAudio); forzar `mpv --ao=pulse`.
- Usar siempre `${TMPDIR}/pulse` como `PULSE_RUNTIME_PATH` hace la ruta del socket predecible (el daemon por defecto nombra el socket según `machine-id`).
