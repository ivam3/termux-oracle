# Scripting en Bash en Termux 🐚⚙️

El shell scripting con **Bash** es el pilar de la automatización en Linux y Termux. Te permite agrupar secuencias de comandos complejos en un único archivo ejecutable para realizar tareas repetitivas de forma instantánea.

---

## ✒️ 1. El Formato del Script: El "Shebang" Correcto

El **Shebang** (`#!`) es la primera línea de un script y le indica al sistema operativo qué intérprete utilizar para ejecutar el código.

Debido a que Termux no sigue el Estándar de Jerarquía de Archivos clásico de Linux, el intérprete de Bash no se encuentra en la ruta tradicional `/bin/bash`. En Termux, se ubica en:
`/data/data/com.termux/files/usr/bin/bash`

### Práctica Recomendada (Shebang Portable):
Para escribir scripts que funcionen tanto en Termux como en cualquier servidor Linux convencional, utiliza el entorno dinámico de búsqueda:
```bash
#!/usr/bin/env bash
```

### Solución a Scripts Externos (`termux-fix-shebang`):
Si descargas un script de internet que contiene la cabecera fija clásica `#!/bin/bash` u `#!/usr/bin/python`, Termux dará un error del tipo `No such file or directory` al intentar ejecutarlo.
Para repararlo de forma automática sin editar el código manualmente, ejecuta:
```bash
termux-fix-shebang nombre_del_script.sh
```
*Este comando reemplaza la ruta del shebang por la ruta interna correcta de Termux.*

---

## 🔑 2. Permisos de Ejecución

Por razones de seguridad, los archivos de texto creados en Linux no tienen permisos de ejecución activos por defecto. Para poder correr un script, debes otorgarle el permiso de ejecución:

```bash
chmod +x mi_script.sh
```

### Cómo ejecutar el script:
1. Asegúrate de estar en el directorio correcto.
2. Ejecuta el script anteponiendo `./` (ruta relativa al directorio actual):
   ```bash
   ./mi_script.sh
   ```

---

## 🛠️ 3. Estructuras de Control Esenciales

A continuación se presentan los bloques de código más utilizados al automatizar tareas en Termux:

### A. Condicionales (`if-else`)
```bash
#!/usr/bin/env bash

NIVEL_BATERIA=15

if [ "$NIVEL_BATERIA" -lt 20 ]; then
    echo "Alerta: Batería baja ($NIVEL_BATERIA%)"
else
    echo "Nivel de batería óptimo ($NIVEL_BATERIA%)"
fi
```
*(Nota: `-lt` significa "less than" o menor que).*

### B. Bucle `for` (Procesamiento por lotes)
Ideal para renombrar archivos, realizar escaneos secuenciales o iterar sobre listas:
```bash
#!/usr/bin/env bash

# Recorrer una lista de hosts en la red local
for host in 192.168.1.1 192.168.1.5 192.168.1.10; do
    echo "Haciendo ping a $host..."
    ping -c 1 $host > /dev/null
    if [ $? -eq 0 ]; then
        echo "Host $host está ACTIVO"
    else
        echo "Host $host está INACTIVO"
    fi
done
```

### C. Bucle `while` (Monitoreo continuo)
Útil para crear servicios persistentes que repiten una acción cada cierto tiempo:
```bash
#!/usr/bin/env bash

while true; do
    echo "Revisando estado de conexión a internet..."
    curl -I https://www.google.com &> /dev/null
    if [ $? -eq 0 ]; then
        echo "Conexión activa."
    else
        echo "Conexión perdida. Intentando reconectar..."
    fi
    sleep 60 # Esperar 60 segundos antes de volver a validar
done
```

---

## 📥 4. Captura de Entrada e Interacción

### Pasar argumentos por consola:
Puedes pasar datos a tu script al momento de invocarlo. Los argumentos se capturan mediante variables numéricas según su posición:
* `$1`: Primer argumento.
* `$2`: Segundo argumento.
* `$@`: Lista completa de todos los argumentos pasivos.
* `$#`: Cantidad total de argumentos pasados.

```bash
# Ejecución: ./backup.sh carpeta_origen destino
ORIGEN=$1
DESTINO=$2
echo "Respaldando de $ORIGEN hacia $DESTINO..."
tar -czf "$DESTINO/respaldo.tar.gz" "$ORIGEN"
```

### Leer datos interactivos (`read`):
```bash
#!/usr/bin/env bash

echo -n "¿Cuál es tu nombre de usuario de GitHub? "
read USUARIO
echo "Clonando repositorios de $USUARIO..."
git clone "https://github.com/$USUARIO/mi-herramienta.git"
```
---

## 💡 Buenas Prácticas
1. **Comillas en las variables**: Envuelve siempre tus variables en comillas dobles (ej. `"$VARIABLE"`) para evitar fallos si el contenido contiene espacios o caracteres especiales.
2. **Depuración (Debug)**: Si tu script falla y no sabes dónde está el error, ejecútalo activando el modo de rastreo:
   ```bash
   bash -x mi_script.sh
   ```
   *Esto imprimirá en pantalla cada línea de código a medida que se ejecuta con sus variables resueltas.*
