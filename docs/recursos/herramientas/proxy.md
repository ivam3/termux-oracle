# proxy

## ¿Qué es proxy?

**proxy** es un comando directo de i-HakLab que ejecuta comandos de terminal a través de Tor y proxychains, enrutando el tráfico de red de forma anónima.

## ¿Para qué es útil?

- Ejecutar comandos con anonimato vía Tor
- Enrutar tráfico de herramientas de red a través de proxychains
- Realizar peticiones sin exponer la IP real

## ¿Cómo se usa?

```bash
proxy <comando>
proxy nmap -sT target.com
proxy curl https://check.torproject.org
```

---

*Nota: Comando directo del ecosistema i-HakLab. Requiere Tor y proxychains-ng configurados.*
