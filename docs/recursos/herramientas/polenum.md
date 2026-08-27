# polenum

## ¿Qué es polenum?

**polenum** es una herramienta de enumeración de políticas de contraseñas en entornos Windows/Active Directory. Usa la librería **Impacket** para conectarse remotamente a una máquina Windows y extraer información sobre la política de contraseñas del dominio o sistema local (longitud mínima, historial, bloqueos, complejidad, etc.).

## ¿Para qué es útil la herramienta?

Polenum es fundamental en pentesting de entornos Windows:

- **Enumeración de política de contraseñas:** Recupera los parámetros de seguridad de contraseñas sin necesidad de credenciales de administrador de dominio (en algunos casos).
- **Evaluación de hardening:** Determina si las políticas son suficientemente estrictas.
- **Preparación de ataques de fuerza bruta:** Conocer la política de bloqueo evita bloquear cuentas durante ataques de contraseña.
- **Auditoría Windows/AD:** Parte del flujo de reconocimiento en Active Directory junto a `enum4linux`, `getadusers`, `kerbrute`.

## Instalación en Termux (i-HakLab)

```bash
apt install polenum
```

El script se instala en `~/.local/share/polenum/polenum.py` e `impacket` se instala vía pip automáticamente.

## ¿Cómo se usa? (Ejemplos básicos)

**Ejemplo 1: Extraer política con usuario y contraseña**

```bash
polenum -u administrator -p Password123 -d 192.168.1.10
```

**Ejemplo 2: Formato compacto usuario:contraseña@ip**

```bash
polenum administrator:Password123@192.168.1.10
```

**Ejemplo 3: Con nombre de dominio**

```bash
polenum -u admin -p pass -d corp.local
```

**Ejemplo 4: Ver ayuda**

```bash
polenum --help
```

## Información que extrae

| Campo | Descripción |
|-------|-------------|
| Minimum password length | Longitud mínima requerida |
| Password history length | Número de contraseñas antiguas recordadas |
| Maximum password age | Vigencia máxima de contraseña |
| Minimum password age | Tiempo mínimo antes de poder cambiarla |
| Password complexity | Si se requieren caracteres mixtos |
| Account lockout threshold | Intentos antes de bloqueo |
| Account lockout duration | Duración del bloqueo (minutos) |

## Flujo de uso típico en pentesting AD

```bash
# 1. Reconocimiento previo con enum4linux
enum4linux -a 192.168.1.10

# 2. Extraer política de contraseñas específicamente
polenum administrator:Password123@192.168.1.10

# 3. Usar la info para configurar ataque de contraseñas
# Si lockout_threshold = 0 → no hay bloqueo → fuerza bruta segura
kerbrute passwordspray --dc 192.168.1.10 -d corp.local users.txt 'Password123'
```

## Referencias

- Repositorio upstream: [Wh1t3Fox/polenum](https://github.com/Wh1t3Fox/polenum)
- Dependencia: [impacket](https://github.com/fortra/impacket)

---
*Esta herramienta es parte del ecosistema i-HakLab para Android/Termux.*
