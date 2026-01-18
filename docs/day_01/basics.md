# Día 1: Fundamentos de Terraform

## Introducción a Terraform

Terraform es una herramienta de **Infraestructura como Código (IaC)** que permite definir y provisionar infraestructura de forma declarativa usando archivos de configuración. Los archivos se escriben en formato HCL (HashiCorp Configuration Language).

---

## Bloques en Terraform

### ¿Qué es un bloque?

Un bloque es una estructura de configuración en Terraform que agrupa argumentos relacionados. La sintaxis general es:

```terraform
TIPO_BLOQUE "ARGUMENTOS_OPCIONALES" {
  argumento = valor
  argumento = valor
}
```

---

## El Bloque `resource`

### Definición

El bloque `resource` es el componente fundamental de Terraform. Define **un recurso que será creado, modificado o destruido** en una infraestructura específica.

### Sintaxis

```terraform
resource "TIPO_DE_RECURSO" "NOMBRE_DEL_RECURSO" {
  argumento1 = valor1
  argumento2 = valor2
}
```

### Componentes del bloque `resource`

1. **`resource`** - Palabra clave que indica que se está definiendo un recurso
2. **`TIPO_DE_RECURSO`** - El tipo específico de recurso a crear (ej: `local_file`, `aws_instance`, etc.)
3. **`NOMBRE_DEL_RECURSO`** - Identificador único dentro de tu configuración (ej: `productos`, `servidor_web`, etc.)
4. **Argumentos** - Parámetros que configuran el recurso

---

## Desglose: El recurso `local_file`

### Tipo de Recurso: `local_file`

`local_file` es un recurso proporcionado por el proveedor **Terraform** que permite:
- **Crear archivos locales** en el sistema de archivos de la máquina donde se ejecuta Terraform
- **Gestionar contenido de archivos** de forma declarativa
- **Mantener el estado** del archivo para futuras actualizaciones

### Nombre del Recurso: `productos`

`productos` es un identificador único que usamos para:
- **Referenciar este recurso** dentro de la configuración de Terraform
- **Acceder a sus atributos** (ej: `local_file.productos.filename`)
- **Crear dependencias** entre recursos si es necesario

Ejemplo de referencia:
```terraform
output "ruta_archivo" {
  value = local_file.productos.filename
}
```

---

## Argumentos del recurso `local_file`

### Argumento: `content`

```terraform
content = "Lista de productos para el mes proximo"
```

- **Descripción**: Define el contenido de texto que se escribirá en el archivo
- **Tipo**: String (cadena de texto)
- **Obligatorio**: No (puede usarse `content` o `content_base64`)
- **Uso**: Especifica qué datos se guardarán dentro del archivo

### Argumento: `filename`

```terraform
filename = "productos.txt"
```

- **Descripción**: Define la ruta y nombre del archivo que se creará
- **Tipo**: String (cadena de texto)
- **Obligatorio**: Sí (requerido)
- **Uso**: Especifica dónde se guardará el archivo en el sistema de archivos
- **Nota**: Se crea relativo al directorio de trabajo actual

---

## Ejemplo Completo Analizado

```terraform
resource "local_file" "productos" {
  content  = "Lista de productos para el mes proximo"
  filename  = "productos.txt"
}
```

### Análisis línea por línea:

| Parte | Explicación |
|-------|------------|
| `resource` | Bloque de Terraform para definir infraestructura |
| `"local_file"` | Tipo de recurso: crear un archivo en el sistema local |
| `"productos"` | Identificador único de este recurso específico |
| `content` | Argumento que define el contenido del archivo |
| `filename` | Argumento que define dónde se guardará el archivo |

### ¿Qué sucede al aplicar esta configuración?

Cuando ejecutas `terraform apply`:
1. Terraform lee la configuración
2. Valida que el recurso `local_file` sea válido
3. Crea un archivo llamado `productos.txt` en el directorio actual
4. Escribe el contenido "Lista de productos para el mes proximo" en ese archivo
5. Guarda el estado en un archivo `terraform.tfstate`

---

## Ciclo de vida del recurso

- **Creación**: El archivo se crea cuando ejecutas `terraform apply` por primera vez
- **Actualización**: Si cambias `content` o `filename` y aplicas de nuevo, Terraform actualiza el archivo
- **Destrucción**: Si ejecutas `terraform destroy`, el archivo se elimina

---

## Argumento alternativo: `content_base64`

Además de `content`, también puedes usar:

```terraform
content_base64 = "..." # Para contenido codificado en base64
```

Esto es útil cuando necesitas almacenar contenido binario o especial.

---

## Comandos principales de Terraform

Los comandos esenciales para trabajar con Terraform son:

| Comando | Descripción |
|---------|------------|
| `terraform init` | Descarga e inicializa los providers necesarios para tu configuración. Terraform infiere automáticamente el provider requerido según los tipos de recursos definidos en tu código |
| `terraform plan` | Genera un plan de ejecución basado en tu código. Muestra qué acciones se realizarán (crear, modificar o destruir recursos). **No modifica la infraestructura real** |
| `terraform apply` | Ejecuta el plan y aplica los cambios reales a la infraestructura. Crea, modifica o destruye recursos según la configuración |
| `terraform destroy` | Elimina todos los recursos que fueron creados por Terraform. Usa con cuidado, ya que es destructivo |

### Flujo típico de trabajo

1. **Escribir configuración** - Define tus recursos en archivos `.tf`
2. **Ejecutar `terraform init`** - Prepara el ambiente
3. **Ejecutar `terraform plan`** - Revisa qué cambios se harán
4. **Ejecutar `terraform apply`** - Aplica los cambios
5. **Ejecutar `terraform destroy`** (cuando sea necesario) - Limpia los recursos

---

## Concepto importante: Inmutabilidad

Terraform trabaja bajo el concepto de **inmutabilidad**. Esto significa:

- **Declarativo, no imperativo**: Describes el estado deseado de tu infraestructura, no los pasos para construirla
- **Estado idempotente**: Puedes ejecutar `terraform apply` múltiples veces y siempre llegarás al mismo estado
- **Infraestructura versionable**: Tu código es la fuente de verdad; todo cambio debe pasar por la configuración
- **Trazabilidad**: Cada cambio en `terraform.tfstate` documenta quién hizo qué y cuándo

Esta característica es fundamental para mantener la consistencia y confiabilidad de tu infraestructura.

## Resumen

| Concepto | Descripción |
|----------|------------|
| Bloque `resource` | Estructura que define un recurso de infraestructura |
| `local_file` | Tipo de recurso que crea archivos locales |
| `productos` | Nombre único del recurso en tu configuración |
| `content` | Argumento que especifica el contenido del archivo |
| `filename` | Argumento que especifica la ruta del archivo |

