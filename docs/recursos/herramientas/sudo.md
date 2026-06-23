# sudo

## ¿Qué es sudo?

**sudo** es un comando directo de i-HakLab que ejecuta comandos o inicia un entorno como falso usuario root (simulado) en Termux, permitiendo operaciones que normalmente requerirían privilegios de superusuario.

## ¿Para qué es útil?

- Ejecutar comandos como root simulado
- Iniciar un entorno con permisos elevados
- Facilitar la ejecución de scripts que esperan un entorno root

## ¿Cómo se usa?

```bash
sudo <comando>
sudo apt install nmap
sudo -s  # Inicia una shell como root simulado
```

---

*Nota: Comando directo del ecosistema i-HakLab. No proporciona privilegios reales de root en Android.*
