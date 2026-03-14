# `count` y `for_each` en Terraform

En Terraform, `count` y `for_each` permiten crear multiples instancias de un mismo recurso a partir de una sola definicion.

Ambos sirven para repetir recursos, pero no funcionan igual ni convienen en los mismos escenarios.

## Idea general

Usas estas meta-arguments cuando necesitas:

- crear varios recursos parecidos
- evitar repetir bloques manualmente
- escalar la configuracion de forma mas dinamica

## 1. `count`

`count` crea varias copias de un recurso segun un numero.

### Ejemplo basico

```hcl
resource "aws_instance" "server" {
  count         = 3
  ami           = "ami-02dfbd4ff395f2a1b"
  instance_type = "t3.micro"

  tags = {
    Name = "server-${count.index}"
  }
}
```

### Que hace

Terraform crea:

- `aws_instance.server[0]`
- `aws_instance.server[1]`
- `aws_instance.server[2]`

## Cuando conviene usar `count`

`count` funciona bien cuando:

- solo necesitas un numero de copias
- las instancias son casi identicas
- la identidad del recurso depende del indice
- no necesitas claves con significado propio

### Caso tipico

```hcl
resource "aws_instance" "worker" {
  count         = 2
  ami           = "ami-02dfbd4ff395f2a1b"
  instance_type = "t3.micro"
}
```

Aqui solo quieres dos instancias iguales. `count` es suficiente.

## Desventaja de `count`

El problema principal de `count` es que depende del indice numerico.

Si cambias el orden o eliminas un elemento intermedio en una lista, Terraform puede interpretar que varios recursos deben recrearse.

### Ejemplo del problema

```hcl
variable "names" {
  default = ["web", "api", "db"]
}

resource "aws_instance" "server" {
  count         = length(var.names)
  ami           = "ami-02dfbd4ff395f2a1b"
  instance_type = "t3.micro"

  tags = {
    Name = var.names[count.index]
  }
}
```

Si luego cambias la lista a:

```hcl
["web", "db"]
```

Terraform puede interpretar que:

- `api` desaparecio
- `db` cambio de posicion

Eso puede generar destrucciones o reemplazos no deseados.

## 2. `for_each`

`for_each` crea multiples instancias de un recurso, pero usando una coleccion con claves o valores unicos.

En vez de depender de indices, depende de una identidad estable.

### Ejemplo con map

```hcl
resource "aws_instance" "server" {
  for_each = {
    web = "t3.micro"
    api = "t3.micro"
    db  = "t3.small"
  }

  ami           = "ami-02dfbd4ff395f2a1b"
  instance_type = each.value

  tags = {
    Name = each.key
  }
}
```

### Que hace

Terraform crea recursos como:

- `aws_instance.server["web"]`
- `aws_instance.server["api"]`
- `aws_instance.server["db"]`

## Cuando conviene usar `for_each`

`for_each` funciona mejor cuando:

- cada recurso tiene una identidad propia
- quieres claves legibles como `web`, `api`, `db`
- la coleccion puede cambiar en orden, pero no quieres recreaciones innecesarias
- cada elemento puede tener configuracion distinta

## Ejemplo con objetos

```hcl
variable "instances" {
  default = {
    web = {
      instance_type = "t3.micro"
    }
    db = {
      instance_type = "t3.small"
    }
  }
}

resource "aws_instance" "server" {
  for_each = var.instances

  ami           = "ami-02dfbd4ff395f2a1b"
  instance_type = each.value.instance_type

  tags = {
    Name = each.key
  }
}
```

Aqui cada recurso tiene una clave estable y datos propios.

## Diferencias principales entre `count` y `for_each`

| Aspecto | `count` | `for_each` |
| --- | --- | --- |
| Tipo de repeticion | Por cantidad | Por clave o valor unico |
| Identidad del recurso | Indice (`[0]`, `[1]`) | Clave (`["web"]`, `["db"]`) |
| Estabilidad ante cambios | Menor | Mayor |
| Legibilidad | Menor | Mayor |
| Mejor caso de uso | Copias casi iguales | Recursos con identidad propia |

## Regla practica

Usa `count` cuando:

- solo necesitas N copias
- el indice es suficiente
- las instancias son casi iguales

Usa `for_each` cuando:

- cada instancia tiene nombre o clave propia
- quieres evitar problemas por reordenamiento
- cada elemento puede tener configuracion distinta

## `count.index` vs `each.key` y `each.value`

Con `count` usas:

```hcl
count.index
```

Con `for_each` usas:

```hcl
each.key
each.value
```

### Ejemplo comparativo

Con `count`:

```hcl
resource "aws_instance" "server" {
  count = 2

  tags = {
    Name = "server-${count.index}"
  }
}
```

Con `for_each`:

```hcl
resource "aws_instance" "server" {
  for_each = {
    web = "frontend"
    api = "backend"
  }

  tags = {
    Name = each.key
    Role = each.value
  }
}
```

## Importancia de `toset()` con `for_each`

Este punto es clave.

`for_each` acepta:

- `map`
- `set`

No acepta una lista simple (`list`) directamente en la mayoria de los casos de uso practicos del recurso, porque necesita elementos con identidad estable.

Si tienes una lista y quieres usarla con `for_each`, normalmente debes convertirla con `toset()`.

### Ejemplo

```hcl
variable "instance_names" {
  default = ["web", "api", "db"]
}

resource "aws_instance" "server" {
  for_each = toset(var.instance_names)

  ami           = "ami-02dfbd4ff395f2a1b"
  instance_type = "t3.micro"

  tags = {
    Name = each.value
  }
}
```

## Por que hace falta `toset()`

Porque una lista:

- tiene orden
- puede tener duplicados
- no representa por si sola una identidad estable para `for_each`

En cambio, un set:

- no depende del orden
- exige valores unicos
- se ajusta mejor al modelo de claves estables

## Que hace `toset()`

`toset()` convierte una lista en un set.

Ejemplo:

```hcl
toset(["web", "api", "db"])
```

Terraform lo tratara como un conjunto de valores unicos.

## Efectos importantes de `toset()`

### 1. Elimina duplicados

```hcl
toset(["web", "api", "web"])
```

Resultado conceptual:

```hcl
["web", "api"]
```

Eso significa que si la lista tiene valores repetidos, el set dejara solo uno.

### 2. Pierde el orden

Un set no garantiza orden.

Por eso no debes depender de posiciones cuando usas `for_each = toset(...)`.

## Cuando usar `toset()` y cuando no

### Si tienes una lista de strings simples

Usa:

```hcl
for_each = toset(var.nombres)
```

### Si necesitas configuracion por clave

Es mejor usar un `map`:

```hcl
for_each = var.instances
```

porque ahi puedes acceder a:

- `each.key`
- `each.value`

con una estructura mas rica y controlada.

## Ejemplo con lista y `toset()`

```hcl
variable "security_group_names" {
  default = ["web-sg", "api-sg", "db-sg"]
}

resource "aws_security_group" "sg" {
  for_each = toset(var.security_group_names)

  name = each.value
}
```

## Ejemplo con map, normalmente mas robusto

```hcl
variable "security_groups" {
  default = {
    web = "web-sg"
    api = "api-sg"
    db  = "db-sg"
  }
}

resource "aws_security_group" "sg" {
  for_each = var.security_groups

  name = each.value

  tags = {
    Name = each.key
  }
}
```

## Casos de uso recomendados

### Usa `count`

- cuando quieres 2, 3 o N copias similares
- cuando no importa tanto la identidad individual
- cuando el indice es suficiente

### Usa `for_each`

- cuando trabajas con nombres de recursos
- cuando cada instancia tiene parametros propios
- cuando quieres minimizar recreaciones por cambios de orden
- cuando modelas recursos a partir de maps o sets

## Error comun

Intentar esto:

```hcl
resource "aws_instance" "server" {
  for_each = ["web", "api", "db"]
}
```

Eso puede fallar o no ser la forma correcta segun el tipo esperado, porque `for_each` requiere una coleccion adecuada para iteracion estable.

La forma correcta seria:

```hcl
resource "aws_instance" "server" {
  for_each = toset(["web", "api", "db"])
}
```

## Buenas practicas

- usa `count` para cantidades simples
- usa `for_each` para recursos con identidad propia
- evita usar `count` con listas que pueden cambiar de orden
- usa `toset()` cuando partas de una lista simple para `for_each`
- usa `map(object(...))` cuando necesites configuraciones mas ricas por elemento

## Resumen

- `count` repite recursos por numero
- `for_each` repite recursos por clave o valor unico
- `for_each` suele ser mas estable y legible
- `toset()` es importante porque convierte listas en sets compatibles con `for_each`
- si necesitas identidad estable y menos recreaciones accidentales, normalmente `for_each` es mejor opcion
