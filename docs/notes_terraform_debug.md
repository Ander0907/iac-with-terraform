# Terraform Logging y Debug

Terraform permite habilitar logs internos para diagnosticar errores de ejecucion, problemas con providers, fallos de red, diferencias de estado y comportamientos inesperados durante `init`, `plan`, `apply` o `destroy`.

Las dos variables de entorno mas usadas para esto son:

- `TF_LOG`
- `TF_LOG_PATH`

## 1. `TF_LOG`

`TF_LOG` activa el logging interno de Terraform y define el nivel de detalle que quieres ver.

Si no esta definida, Terraform normalmente no muestra logs de debug internos.

### Sintaxis general

```powershell
$env:TF_LOG="INFO"
terraform plan
```

## Niveles de logging

Terraform soporta varios niveles de log. Mientras mas alto sea el detalle, mas ruido tendras en la salida.

### `TRACE`

Es el nivel mas detallado.

**Cuando usarlo:**

- depuracion profunda
- errores dificiles de reproducir
- analisis de interaccion entre Terraform y providers

**Ventaja:**
Muestra casi todo lo que Terraform esta haciendo.

**Desventaja:**
Genera muchisima salida y puede incluir informacion sensible.

### `DEBUG`

Muestra detalles tecnicos amplios, pero menos extremos que `TRACE`.

**Cuando usarlo:**

- investigar errores en providers
- revisar flujo interno de ejecucion
- entender por que un comando falla

### `INFO`

Muestra eventos importantes del proceso sin llegar al nivel de detalle tecnico completo.

**Cuando usarlo:**

- diagnostico general
- revisar comportamiento de alto nivel
- obtener contexto sin saturarte de logs

### `WARN`

Muestra advertencias y situaciones potencialmente problematicas.

**Cuando usarlo:**

- revisar problemas no criticos
- buscar señales de configuracion riesgosa o incompleta

### `ERROR`

Muestra solo errores.

**Cuando usarlo:**

- obtener una salida mas limpia
- registrar unicamente fallos relevantes

## Resumen rapido de niveles

| Nivel | Detalle | Uso recomendado |
| --- | --- | --- |
| `TRACE` | Maximo | Depuracion profunda |
| `DEBUG` | Alto | Fallos tecnicos y providers |
| `INFO` | Medio | Diagnostico general |
| `WARN` | Bajo | Advertencias |
| `ERROR` | Minimo | Solo errores |

## 2. `TF_LOG_PATH`

`TF_LOG_PATH` permite guardar los logs en un archivo en vez de depender solo de la salida de consola.

Esto es util porque con niveles altos como `DEBUG` o `TRACE` la terminal puede llenarse muy rapido.

### Sintaxis general

```powershell
$env:TF_LOG="DEBUG"
$env:TF_LOG_PATH="terraform-debug.log"
terraform apply
```

Con eso:

- `TF_LOG` define el nivel
- `TF_LOG_PATH` define el archivo donde se escriben los logs

## Importante sobre `TF_LOG_PATH`

`TF_LOG_PATH` no sirve por si sola.

Debes definir tambien `TF_LOG`, porque `TF_LOG_PATH` solo indica **donde guardar** el log, pero no activa el logging por cuenta propia.

Ejemplo correcto:

```powershell
$env:TF_LOG="INFO"
$env:TF_LOG_PATH="terraform.log"
terraform plan
```

Ejemplo incompleto:

```powershell
$env:TF_LOG_PATH="terraform.log"
terraform plan
```

En ese caso probablemente no se genere el log porque no activaste `TF_LOG`.

## Ejemplos practicos

### Ver logs en consola

```powershell
$env:TF_LOG="DEBUG"
terraform init
```

### Guardar logs en archivo

```powershell
$env:TF_LOG="TRACE"
$env:TF_LOG_PATH="terraform-trace.log"
terraform plan
```

### Limpiar variables al terminar

```powershell
Remove-Item Env:TF_LOG
Remove-Item Env:TF_LOG_PATH
```

Esto ayuda a que no dejes logging activo para futuras ejecuciones por accidente.

## Casos de uso comunes

- errores al descargar o inicializar providers
- problemas de autenticacion con AWS u otros providers
- fallos al leer o escribir estado remoto
- errores de red, timeout o DNS
- diferencia inesperada entre configuracion, estado y proveedor
- depuracion de recursos que no se crean como esperabas

## Ejemplo de flujo de diagnostico

Si `terraform plan` falla y no queda claro por que:

```powershell
$env:TF_LOG="DEBUG"
$env:TF_LOG_PATH="plan-debug.log"
terraform plan
```

Luego revisas el archivo `plan-debug.log` para identificar:

- llamadas al provider
- errores de autenticacion
- respuestas inesperadas
- mensajes internos de Terraform

## Buenas practicas

- empieza con `INFO` o `DEBUG`; usa `TRACE` solo si realmente hace falta
- prefiere `TF_LOG_PATH` cuando el log sea grande
- elimina o protege los archivos de log despues de usarlos
- no subas logs a git si contienen datos sensibles
- evita dejar `TF_LOG` activo en sesiones normales

## Riesgo de informacion sensible

Los logs de Terraform pueden incluir datos sensibles como:

- variables
- rutas locales
- IDs de recursos
- respuestas del provider
- detalles de autenticacion o contexto de ejecucion

Por eso, antes de compartir un log:

- revisalo
- sanitiza secretos
- evita publicarlo completo en repositorios o tickets abiertos

## Resumen

- `TF_LOG` activa y controla el nivel de logging
- `TF_LOG_PATH` guarda los logs en un archivo
- los niveles principales son `TRACE`, `DEBUG`, `INFO`, `WARN` y `ERROR`
- `TRACE` es util para depuracion profunda, pero genera mucho ruido
- siempre conviene desactivar estas variables al terminar el diagnostico
