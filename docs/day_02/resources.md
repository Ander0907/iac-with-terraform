# Día 2: Recursos, Meta-argumentos y Reutilización

## Introducción

El día 2 explora conceptos avanzados de Terraform como el meta-argumento `count`, nuevos tipos de recursos y cómo aplicar principios de desarrollo como DRY (Don't Repeat Yourself).

---

## El tipo de recurso: `random_string`

### ¿Qué es `random_string`?

`random_string` es un recurso proporcionado por el proveedor **Random** que genera cadenas de caracteres aleatorias. Es muy útil para:
- Crear identificadores únicos para recursos
- Generar sufijos en nombres de archivos
- Crear valores aleatorios para testing
- Asegurar que los nombres de recursos sean únicos

### Sintaxis básica

```terraform
resource "random_string" "nombre" {
  length  = número
  upper   = booleano
  lower   = booleano
  numeric = booleano
  special = booleano
}
```

### Argumentos principales

| Argumento | Tipo | Descripción |
|-----------|------|------------|
| `length` | número | Longitud de la cadena aleatoria a generar. **Obligatorio** |
| `upper` | booleano | Si incluir mayúsculas (A-Z). Por defecto: `true` |
| `lower` | booleano | Si incluir minúsculas (a-z). Por defecto: `true` |
| `numeric` | booleano | Si incluir números (0-9). Por defecto: `true` |
| `special` | booleano | Si incluir caracteres especiales. Por defecto: `true` |

### Ejemplo del día 2

```terraform
resource "random_string" "suffix" {
    count = 5
    length  = 4
    upper = false
    lower = true
    numeric = false
    special = false
}
```

**Explicación:**
- Genera 5 cadenas aleatorias diferentes
- Cada cadena tiene 4 caracteres de longitud
- Solo contiene letras minúsculas (a-z)
- Sin mayúsculas, números ni caracteres especiales

---

## Meta-argumento: `count`

### ¿Qué es `count`?

`count` es un **meta-argumento** que permite crear múltiples instancias del mismo recurso sin repetir código. Es el principio de **DRY (Don't Repeat Yourself)** en acción.

### Sintaxis

```terraform
resource "tipo_recurso" "nombre" {
  count = número
  # resto de configuración
}
```

### Cómo funciona

Cuando usas `count = 5`, Terraform crea 5 instancias del recurso numeradas de 0 a 4.

Para acceder a cada instancia:
```terraform
recurso.nombre[0]  # Primera instancia
recurso.nombre[1]  # Segunda instancia
recurso.nombre[4]  # Última instancia
```

### Variable especial: `count.index`

Dentro de un bloque con `count`, puedes usar `count.index` para obtener el número de la instancia actual (0, 1, 2, etc.).

**Ejemplo:**
```terraform
filename = "archivo-${count.index}.txt"
# Genera: archivo-0.txt, archivo-1.txt, archivo-2.txt, etc.
```

---

## Interpolación: Referenciando otros recursos

### ¿Qué es la interpolación?

La interpolación permite usar valores de un recurso en otro recurso mediante la sintaxis `${...}`.

### Sintaxis

```terraform
${tipo_recurso.nombre[indice].atributo}
```

### Ejemplo del día 2

```terraform
filename = "products-${random_string.suffix[count.index].id}.txt"
```

**Explicación:**
- `random_string.suffix` - Referencia al recurso random_string
- `[count.index]` - Selecciona la instancia en la posición actual
- `.id` - Accede al atributo `id` (la cadena aleatoria generada)
- `"products-${...}.txt"` - Integra el valor aleatorio en el nombre del archivo

**Resultado:**
```
products-abc1.txt
products-def2.txt
products-ghi3.txt
products-jkl4.txt
products-mno5.txt
```

---

## Tipo de recurso: `local_file` con `count`

### Usando `count` con `local_file`

```terraform
resource "local_file" "products" {
    count = 5
    content  = "List of products"
    filename = "products-${random_string.suffix[count.index].id}.txt"
}
```

**¿Qué sucede?**

1. Terraform leerá el recurso `random_string` y obtendrá 5 valores aleatorios
2. Para cada uno de los 5 valores, creará un archivo `local_file`
3. Cada archivo tendrá un nombre único combinando "products-" + cadena aleatoria + ".txt"
4. Todos los archivos tendrán el mismo contenido: "List of products"

### Ventajas del enfoque con `count`

✓ **DRY**: Una sola definición de recurso, sin repetición
✓ **Escalable**: Si necesitas 100 archivos en lugar de 5, solo cambias `count = 100`
✓ **Mantenible**: Cambios en la lógica se aplican a todas las instancias automáticamente
✓ **Limpio**: Código legible y profesional

---

## Concepto: DRY (Don't Repeat Yourself)

### ¿Qué es DRY?

DRY es un principio de desarrollo que dice:
> "Cada pieza de conocimiento debe tener una única representación inequívoca en el sistema"

### En el contexto de Terraform

**Sin DRY (Mal):**
```terraform
resource "local_file" "file1" {
  content  = "List of products"
  filename = "products-1.txt"
}

resource "local_file" "file2" {
  content  = "List of products"
  filename = "products-2.txt"
}

resource "local_file" "file3" {
  content  = "List of products"
  filename = "products-3.txt"
}
# ... repetición infinita
```

**Con DRY (Bien):**
```terraform
resource "local_file" "products" {
  count    = 5
  content  = "List of products"
  filename = "products-${count.index}.txt"
}
```

### Beneficios de DRY

- **Menos código** - Reduces líneas innecesarias
- **Menos errores** - Un cambio afecta a todas las instancias
- **Mejor mantenimiento** - Más fácil actualizar lógica
- **Mayor claridad** - La intención es evidente

---

## Comando: `terraform show`

### ¿Qué es `terraform show`?

`terraform show` es un comando que muestra el estado actual de los recursos que Terraform ha creado. Permite visualizar:
- Todos los recursos gestionados por Terraform
- Sus atributos y valores actuales
- Las relaciones entre recursos

### Sintaxis

```bash
terraform show
```

### Salida típica

```
# random_string.suffix[0]:
resource "random_string" "suffix" {
    id      = "xkcd"
    length  = 4
    lower   = true
    upper   = false
}

# random_string.suffix[1]:
resource "random_string" "suffix" {
    id      = "qwer"
    length  = 4
    lower   = true
    upper   = false
}

# local_file.products[0]:
resource "local_file" "products" {
    content             = "List of products"
    filename            = "products-xkcd.txt"
    id                  = "abc123..."
}
```

### Cuándo usar `terraform show`

- **Verificar** - Confirmar que los recursos se crearon correctamente
- **Debuggear** - Revisar valores de atributos
- **Auditar** - Ver qué recursos está gestionando Terraform
- **Documentar** - Capturar el estado actual de la infraestructura

---

## Flujo de trabajo del día 2

1. **Definir generador aleatorio** con `random_string` y `count`
2. **Crear archivos** con `local_file` usando valores generados
3. **Aplicar configuración** con `terraform apply`
4. **Visualizar recursos** con `terraform show`
5. **Verificar resultados** - Revisar los archivos creados con nombres únicos

---

## Resumen

| Concepto | Descripción |
|----------|------------|
| `random_string` | Recurso que genera cadenas aleatorias |
| `count` | Meta-argumento para crear múltiples instancias |
| `count.index` | Variable que contiene el número de instancia (0, 1, 2...) |
| Interpolación | Integrar valores de un recurso en otro mediante `${}` |
| DRY | Principio de evitar repetición de código |
| `terraform show` | Comando para visualizar el estado actual de recursos |

