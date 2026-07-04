# i-HakLab Reference

i-HakLab v3.12 es un laboratorio de hacking para Termux/Android creado por @Ivam3byCinderella.

## Comando principal
```bash
i-Haklab <opción> [argumentos]
```

## Setting Options
| Comando | Función |
|---------|---------|
| `about <tool>` | Info sobre herramienta |
| `aptup` | Actualiza Termux manualmente |
| `help` | Muestra ayuda |
| `passwd set\|new` | Configura login |
| `pd <distro>` | Ejecuta distro Linux en proot |
| `setapikey` | Configura API keys |
| `setshell` | Cambia shell (bash/zsh/fish) |
| `setuser` | Configura nombre de usuario |
| `show alltools\|instatools\|books\|tutorials` | Lista herramientas/libros/tutoriales |
| `speedtest` | Prueba de velocidad |
| `weechat` | Conecta IRC |
| `Xwayland` | Escritorio XFCE4 sobre Wayland |

## Automatization Options
| Comando | Función |
|---------|---------|
| `androforensic secretCodes\|airscope\|dumpsys\|extract` | Forense Android vía ADB |
| `backup create\|restore` | Backup de Termux |
| `bruteforce ftp\|mail\|ssh\|telnet` | Fuerza bruta |
| `chatAI` | Asistente IA vía OpenAI |
| `msf dirscan\|embed\|payapk\|payexe\|paypdf\|shodan` | Automatizaciones Metasploit |
| `tunnel -p <port> -s <subdomain>` | TCP port forwarding |
| `qemufy <file.zip\|rm>` | Máquinas virtuales QEMU sin root |
| `servers4test` | Laboratorios vulnerables (bWAPP/DVWA/mutillidae) |
| `4share localtunnel\|localhost.run\|cloudflared` | Servidor para compartir archivos |
| `phonescan <number>` | Escaneo telefónico |

## Direct Commands (sin prefijo i-Haklab)
`apt`, `adminfiles`, `cmd`, `fixer`, `gitbrowsering`, `lock`, `mypip`, `proxy`, `rmcache`, `serverapache`, `serverphp`, `sudo`, `traductor`, `postgresql`

## Credenciales por defecto
- Login i-HakLab: `Ivam3byCinderella`
- 4share: `Admin:password`
- servers4test bWAPP: `bee:bug`
- servers4test DVWA DB: `root:root`

## Comandos útiles para el agente
```bash
# Ver todas las herramientas disponibles
i-Haklab show alltools
# Información de una herramienta
i-Haklab about <tool>
# Ver tutoriales (incluye "termux tips cap 1.1" y "termux tips cap 14")
i-Haklab show tutorials
```

## Archivos clave de i-HakLab
| Ruta | Contenido |
|------|-----------|
| `~/.local/bin/i-Haklab` | Comando principal |
| `~/.local/bin/apt` | Wrapper de apt |
| `~/.local/bin/npm` | Wrapper de npm |
| `~/.local/etc/i-Haklab/functions` | Funciones de shell internas |
| `~/.local/etc/i-Haklab/variables` | Variables internas (no editar) |
| `~/.local/etc/i-Haklab/envvariables` | Variables de entorno |
| `~/.local/etc/i-Haklab/Tools/listoftools` | Lista maestra de herramientas |
| `~/.local/etc/i-Haklab/Tools/listofpkg2conf` | Paquetes con post-configuración |
| `~/.local/etc/i-Haklab/Tools/Readme/` | Docs individuales de cada herramienta |
| `~/.local/libexec/pkg2conf` | Orquestador post-instalación |
| `~/.local/libexec/i-Haklab/setshell` | Cambio de shell |
| `$PREFIX/usr/bin/fixer` | Diagnóstico y reparación |
| `$PREFIX/share/man/man1/i-Haklab.1` | Man page |

## Wrappers (comportamiento)
- `apt install <herramienta>` → detecta si es Python/Node/Ruby y redirige a pip/npm/gem
- Si es nativo, delega a `$PREFIX/bin/apt`
- Post-instalación ejecuta `pkg2conf` si está en `listofpkg2conf`
- `npm install <paquete>` → normaliza alias, ejecuta pkg2conf
