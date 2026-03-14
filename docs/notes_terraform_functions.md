# Funciones de Terraform con `terraform console`

`terraform console` es una consola interactiva que permite evaluar expresiones de Terraform en tiempo real.

Es muy util para:

- probar funciones
- entender estructuras de datos
- validar transformaciones antes de usarlas en un recurso
- depurar variables, listas, mapas y objetos

## Que es `terraform console`

Es un comando que abre una consola REPL de Terraform.

Ejemplo:

```bash
terraform console
```

Una vez dentro, puedes escribir expresiones como:

```hcl
upper("hola")
length(["a", "b", "c"])
```

y Terraform te devuelve el resultado inmediatamente.

## Casos de uso de `terraform console`

- probar funciones antes de meterlas en el codigo
- inspeccionar valores de variables
- entender salidas de `for_each`, `count`, `toset`, `tomap`
- validar expresiones complejas
- aprender como Terraform trata listas, sets, maps y objetos

## 1. Funciones de string

Estas funciones sirven para transformar texto.

### `upper()`

Convierte un string a mayusculas.

**Ejemplo en consola:**

```hcl
upper("terraform")
```

**Resultado:**

```hcl
"TERRAFORM"
```

**Caso de uso:**

- normalizar nombres o tags

### `lower()`

Convierte un string a minusculas.

```hcl
lower("DEV")
```

Resultado:

```hcl
"dev"
```

**Caso de uso:**

- estandarizar nombres de entorno

### `title()`

Convierte un string a formato tipo titulo.

```hcl
title("hello world")
```

Resultado:

```hcl
"Hello World"
```

**Caso de uso:**

- etiquetas legibles o nombres amigables

### `trim()`

Quita caracteres al inicio y al final.

```hcl
trim("  dev  ", " ")
```

Resultado:

```hcl
"dev"
```

**Caso de uso:**

- limpiar entradas de variables

### `replace()`

Reemplaza una parte de un string.

```hcl
replace("app-dev", "dev", "prod")
```

Resultado:

```hcl
"app-prod"
```

**Caso de uso:**

- construir nombres dinamicos

### `split()`

Divide un string en una lista.

```hcl
split(",", "web,api,db")
```

Resultado:

```hcl
tolist([
  "web",
  "api",
  "db",
])
```

**Caso de uso:**

- convertir datos tipo CSV a lista

### `join()`

Une una lista en un string.

```hcl
join("-", ["web", "dev", "01"])
```

Resultado:

```hcl
"web-dev-01"
```

**Caso de uso:**

- construir nombres de recursos

### `format()`

Permite interpolar valores con formato.

```hcl
format("server-%02d", 3)
```

Resultado:

```hcl
"server-03"
```

**Caso de uso:**

- nombres consistentes con padding numerico

## 2. Funciones de listas y colecciones

Estas funciones ayudan a transformar listas, sets y secuencias.

### `length()`

Cuenta cuantos elementos tiene una coleccion o cuantos caracteres tiene un string.

```hcl
length(["web", "api", "db"])
```

Resultado:

```hcl
3
```

**Caso de uso:**

- usar con `count`
- validar tamanos de listas

### `concat()`

Une varias listas.

```hcl
concat(["web"], ["api", "db"])
```

Resultado:

```hcl
[
  "web",
  "api",
  "db",
]
```

**Caso de uso:**

- combinar listas base con listas opcionales

### `element()`

Obtiene un elemento por indice.

```hcl
element(["web", "api", "db"], 1)
```

Resultado:

```hcl
"api"
```

**Caso de uso:**

- seleccionar posiciones concretas

### `slice()`

Devuelve una parte de una lista.

```hcl
slice(["a", "b", "c", "d"], 1, 3)
```

Resultado:

```hcl
[
  "b",
  "c",
]
```

**Caso de uso:**

- tomar subconjuntos de subnets o zonas

### `distinct()`

Elimina duplicados de una lista.

```hcl
distinct(["web", "api", "web"])
```

Resultado:

```hcl
[
  "web",
  "api",
]
```

**Caso de uso:**

- limpiar listas antes de transformarlas

### `sort()`

Ordena una lista de strings.

```hcl
sort(["db", "web", "api"])
```

Resultado:

```hcl
[
  "api",
  "db",
  "web",
]
```

**Caso de uso:**

- garantizar orden estable en salidas o expresiones

### `reverse()`

Invierte el orden de una lista.

```hcl
reverse(["a", "b", "c"])
```

Resultado:

```hcl
[
  "c",
  "b",
  "a",
]
```

### `flatten()`

Convierte listas anidadas en una lista plana.

```hcl
flatten([["web", "api"], ["db"]])
```

Resultado:

```hcl
[
  "web",
  "api",
  "db",
]
```

**Caso de uso:**

- unir resultados de bucles o estructuras anidadas

## 3. Funciones de mapas y objetos

Estas funciones son muy utiles cuando trabajas con `for_each`, tags y configuraciones por entorno.

### `keys()`

Devuelve las claves de un mapa.

```hcl
keys({
  web = "t3.micro"
  db  = "t3.small"
})
```

Resultado:

```hcl
[
  "db",
  "web",
]
```

**Caso de uso:**

- inspeccionar mapas
- generar listas de nombres

### `values()`

Devuelve los valores de un mapa.

```hcl
values({
  web = "t3.micro"
  db  = "t3.small"
})
```

Resultado:

```hcl
[
  "t3.small",
  "t3.micro",
]
```

### `lookup()`

Busca una clave en un mapa y permite valor por defecto.

```hcl
lookup({ env = "dev" }, "env", "default")
```

Resultado:

```hcl
"dev"
```

Si la clave no existe:

```hcl
lookup({ env = "dev" }, "region", "us-east-1")
```

Resultado:

```hcl
"us-east-1"
```

**Caso de uso:**

- valores opcionales en mapas
- configuracion por entorno

### `merge()`

Combina mapas.

```hcl
merge(
  { Environment = "dev" },
  { Owner = "team-platform" }
)
```

Resultado:

```hcl
{
  "Environment" = "dev"
  "Owner" = "team-platform"
}
```

**Caso de uso:**

- unir tags globales con tags especificos

## 4. Funciones de conversion

Estas funciones convierten tipos y son clave cuando trabajas con `count`, `for_each` o variables.

### `toset()`

Convierte una lista en set.

```hcl
toset(["web", "api", "web"])
```

Resultado conceptual:

```hcl
toset([
  "api",
  "web",
])
```

**Caso de uso:**

- usar listas en `for_each`
- eliminar duplicados

### `tolist()`

Convierte una coleccion a lista.

```hcl
tolist(toset(["web", "api"]))
```

**Caso de uso:**

- normalizar salidas o trabajar con funciones que esperan lista

### `tomap()`

Convierte un valor compatible en mapa.

```hcl
tomap({
  env = "dev"
  app = "billing"
})
```

**Caso de uso:**

- normalizar estructuras dinamicas

### `tonumber()`

Convierte un string numerico en numero.

```hcl
tonumber("3")
```

Resultado:

```hcl
3
```

**Caso de uso:**

- variables de entrada que llegan como string

### `tostring()`

Convierte un valor a string.

```hcl
tostring(123)
```

Resultado:

```hcl
"123"
```

## 5. Funciones condicionales y de control

Estas funciones ayudan a manejar valores faltantes o expresiones mas seguras.

### `coalesce()`

Devuelve el primer valor no nulo ni vacio.

```hcl
coalesce("", null, "dev")
```

Resultado:

```hcl
"dev"
```

**Caso de uso:**

- valores por defecto
- priorizar varias fuentes de entrada

### `try()`

Prueba expresiones y devuelve la primera que no falle.

```hcl
try(var.config.region, "us-east-1")
```

**Caso de uso:**

- atributos opcionales
- evitar errores si un campo no existe

### `can()`

Indica si una expresion puede evaluarse sin error.

```hcl
can(var.config.region)
```

**Caso de uso:**

- validaciones condicionales
- comprobaciones previas antes de acceder a atributos

## 6. Funciones de archivos y serializacion

Muy utiles cuando trabajas con plantillas, policies o archivos externos.

### `file()`

Lee el contenido de un archivo.

```hcl
file("user_data.sh")
```

**Caso de uso:**

- cargar scripts de `user_data`
- leer templates o configuraciones

### `jsonencode()`

Convierte un valor Terraform a JSON.

```hcl
jsonencode({
  env = "dev"
  app = "billing"
})
```

Resultado:

```hcl
"{\"app\":\"billing\",\"env\":\"dev\"}"
```

**Caso de uso:**

- generar politicas IAM
- construir payloads JSON

### `jsondecode()`

Convierte JSON a estructura Terraform.

```hcl
jsondecode("{\"env\":\"dev\",\"app\":\"billing\"}")
```

Resultado:

```hcl
{
  "app" = "billing"
  "env" = "dev"
}
```

**Caso de uso:**

- consumir archivos JSON externos

### `yamldecode()`

Convierte YAML en estructura Terraform.

```hcl
yamldecode("env: dev\napp: billing")
```

**Caso de uso:**

- cargar configuraciones externas en YAML

## 7. Funciones utiles para redes y CIDR

Muy usadas en infraestructura real.

### `cidrsubnet()`

Calcula una subred a partir de una red base.

```hcl
cidrsubnet("10.0.0.0/16", 8, 1)
```

**Caso de uso:**

- generar subnets de forma dinamica

### `cidrhost()`

Devuelve una IP concreta dentro de una red CIDR.

```hcl
cidrhost("10.0.1.0/24", 10)
```

**Caso de uso:**

- calcular IPs concretas dentro de un rango

## Ejemplos utiles para practicar en `terraform console`

### Probar una transformacion de nombres

```hcl
format("%s-%s", lower("APP"), terraform.workspace)
```

### Preparar una lista para `for_each`

```hcl
toset(distinct(["web", "api", "web"]))
```

### Unir tags globales y locales

```hcl
merge(
  { Environment = "dev", Owner = "platform" },
  { Name = "web-01" }
)
```

### Obtener un valor opcional

```hcl
lookup({ instance_type = "t3.micro" }, "instance_type", "t2.micro")
```

## Buenas practicas al usar `terraform console`

- prueba expresiones complejas primero en consola
- valida conversiones de tipos antes de usarlas con `for_each`
- usa `jsonencode()` para ver claramente estructuras anidadas
- combina `try()` y `lookup()` para manejar valores opcionales
- aprovecha la consola para entender como Terraform interpreta tus datos

## Resumen

- `terraform console` sirve para evaluar expresiones de Terraform en tiempo real
- es ideal para aprender funciones y depurar transformaciones
- funciones como `length`, `merge`, `lookup`, `toset`, `try` y `jsonencode` son de las mas utiles en trabajo real
- practicar estas funciones en consola ayuda a evitar errores antes de ejecutar `plan` o `apply`
