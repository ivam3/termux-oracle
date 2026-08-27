# azure-cli (az)

## ¿Qué es azure-cli?

**Azure CLI** (`az`) es la interfaz de línea de comandos oficial de Microsoft para gestionar servicios y recursos de la nube Azure directamente desde la terminal. Permite administrar máquinas virtuales, redes, bases de datos, contenedores, identidades, almacenamiento y cientos de servicios más sin necesidad de usar el portal web.

## ¿Para qué es útil la herramienta?

En el contexto de i-HakLab, azure-cli es útil para:

- **Reconocimiento de infraestructura Azure:** Enumerar recursos, permisos, subscripciones y roles IAM durante auditorías de cloud.
- **Gestión de entornos de laboratorio:** Crear y destruir VMs, redes y servicios de prueba de forma automatizada.
- **Pentesting Cloud (CSPM):** Verificar misconfigurations en Storage Accounts, Role Assignments, Network Security Groups, etc.
- **Automatización DevOps:** Integrar despliegues y CI/CD desde Termux.

## Instalación en Termux (i-HakLab)

```bash
apt install azure-cli
```

> [!NOTE]
> Requiere `python3.10` del repositorio `tur-repo`. El `postinst` instala azure-cli v2.89.1 con `pip install --target ${PREFIX}/opt/az`.

## ¿Cómo se usa? (Ejemplos básicos)

**Ejemplo 1: Autenticarse con Azure**

```bash
az login
# Abre navegador o muestra código de dispositivo
```

**Ejemplo 2: Listar subscripciones**

```bash
az account list --output table
```

**Ejemplo 3: Listar grupos de recursos**

```bash
az group list --output table
```

**Ejemplo 4: Listar VMs**

```bash
az vm list --output table
```

**Ejemplo 5: Enumerar permisos de un usuario (OSINT/pentest)**

```bash
az role assignment list --assignee <user@domain.com> --output table
```

**Ejemplo 6: Verificar Storage Accounts públicos**

```bash
az storage account list --query "[?allowBlobPublicAccess==true]" --output table
```

## Flujo de reconocimiento Azure en auditorías

```bash
# 1. Login
az login

# 2. Ver subscripciones accesibles
az account list

# 3. Cambiar subscripción
az account set --subscription "<ID>"

# 4. Enumerar recursos
az resource list --output table

# 5. Verificar NSGs (Network Security Groups)
az network nsg list --output table
az network nsg rule list --nsg-name <nombre> -g <grupo>
```

## Consideraciones en Termux

- Requiere Python 3.10 de `tur-repo` (no el Python nativo de Termux).
- El binario principal es `az` (no `azure-cli`).
- El login interactivo requiere acceso a navegador o código de dispositivo.

## Referencias

- Documentación oficial: [learn.microsoft.com/cli/azure](https://learn.microsoft.com/cli/azure)
- Repositorio: [Azure/azure-cli](https://github.com/Azure/azure-cli)

---
*Esta herramienta es parte del ecosistema i-HakLab para Android/Termux.*
