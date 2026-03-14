# Terraform Import

`terraform import` permite incorporar a Terraform un recurso que ya existe en el proveedor, para que empiece a ser gestionado desde el estado (`terraform.tfstate`).

En otras palabras:

- el recurso ya existe en AWS, Azure, GCP, etc.
- Terraform aun no lo controla en su estado
- `terraform import` lo registra en el estado para que Terraform lo reconozca

## Idea principal

`terraform import` **no crea** infraestructura.

Tampoco "descubre y escribe" automaticamente toda la configuracion en tus archivos `.tf` en el flujo clasico.

Lo que hace es:

1. tomar un recurso existente
2. asociarlo a una direccion de recurso en Terraform
3. guardarlo en el estado

Despues de eso, tu configuracion `.tf` debe coincidir con el recurso importado para evitar cambios inesperados en `terraform plan`.

## Cuando se usa

`terraform import` sirve cuando quieres empezar a gestionar con Terraform algo que fue creado fuera de Terraform.

### Casos de uso comunes

- adoptar infraestructura creada manualmente en la consola de AWS
- migrar recursos existentes a Terraform
- recuperar el control de un recurso despues de perder parte del estado
- incorporar recursos legacy a un proyecto IaC
- reorganizar gestion de recursos entre estados o proyectos

## Sintaxis basica

```bash
terraform import <direccion_del_recurso> <id_del_proveedor>
```

### Partes del comando

- `<direccion_del_recurso>`: la direccion Terraform del recurso en tu codigo
- `<id_del_proveedor>`: el identificador real del recurso en el proveedor

## Ejemplo simple con EC2

Supongamos que ya existe una instancia EC2 en AWS con este ID:

```bash
i-0abc123def4567890
```

Y en tu codigo tienes:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-02dfbd4ff395f2a1b"
  instance_type = "t3.micro"
}
```

El import seria:

```bash
terraform import aws_instance.web i-0abc123def4567890
```

### Que pasa despues

Despues del import:

- la instancia queda registrada en el estado
- Terraform ya la "ve" como gestionada
- si tu configuracion no coincide exactamente con el recurso real, `terraform plan` puede proponer cambios

## Ejemplo con Security Group

```hcl
resource "aws_security_group" "web_sg" {
  name = "web-sg"
}
```

Si el Security Group ya existe con ID:

```bash
sg-0123456789abcdef0
```

Puedes importarlo asi:

```bash
terraform import aws_security_group.web_sg sg-0123456789abcdef0
```

## Ejemplo con modulos

Si el recurso esta dentro de un modulo, debes usar la direccion completa.

```bash
terraform import module.network.aws_vpc.main vpc-0123456789abcdef0
```

## Ejemplo con `for_each`

Cuando el recurso usa `for_each`, la direccion debe incluir la clave:

```bash
terraform import 'aws_instance.servers["web"]' i-0abc123def4567890
```

## Ejemplo con `count`

Cuando el recurso usa `count`, debes indicar el indice:

```bash
terraform import aws_instance.servers[0] i-0abc123def4567890
```

## Flujo recomendado de trabajo

Un flujo razonable para importar recursos es este:

1. escribir primero el bloque `resource` en tu codigo
2. ejecutar `terraform init` si hace falta
3. correr `terraform import`
4. ejecutar `terraform plan`
5. ajustar la configuracion hasta que el plan no proponga cambios no deseados

## Muy importante: `import` no reemplaza la configuracion

Este es el punto que mas confusion genera.

`terraform import` agrega el recurso al **estado**, pero no significa que Terraform ya tenga toda la configuracion perfecta en tus archivos.

Si importas una EC2 y tu bloque solo tiene esto:

```hcl
resource "aws_instance" "web" {
  instance_type = "t3.micro"
}
```

pero la instancia real tambien tiene:

- subnet
- security groups
- tags
- key pair
- volumenes

entonces `terraform plan` puede mostrar diferencias y tratar de modificar el recurso para alinearlo con tu configuracion actual.

Por eso, despues de importar, debes revisar bien el recurso y completar tu codigo `.tf`.

## Casos donde `terraform import` es muy util

### 1. Infraestructura creada manualmente

Ejemplo:

- alguien creo una VPC desde consola
- ahora quieres gestionarla con Terraform

### 2. Migracion a IaC

Ejemplo:

- tienes recursos existentes en AWS
- quieres pasar a una base versionada en git y gestionada con Terraform

### 3. Recuperacion de estado

Ejemplo:

- el recurso sigue existiendo en AWS
- pero se perdio el estado o se saco del estado por error

### 4. Separacion o reorganizacion

Ejemplo:

- estas moviendo recursos entre proyectos o modulos
- necesitas que un nuevo estado empiece a gestionarlos

## Limitaciones y riesgos

`terraform import` es potente, pero tiene varias limitaciones:

- no construye automaticamente toda la definicion final del recurso en el flujo tradicional
- si importas mal la direccion, el estado quedara inconsistente con tu intencion
- si la configuracion no coincide, Terraform intentara corregir el recurso
- algunos recursos tienen IDs o formatos de importacion poco intuitivos

## Buenas practicas

- escribe primero el recurso en `.tf` antes de importar
- importa un recurso a la vez cuando estas aprendiendo o migrando
- ejecuta `terraform plan` inmediatamente despues del import
- revisa tags, redes, dependencias y atributos importantes
- haz backup del estado si el entorno es sensible
- evita importar a ciegas sin entender la direccion del recurso

## Ejemplo de flujo completo

```bash
terraform init
terraform import aws_instance.web i-0abc123def4567890
terraform plan
```

Si el `plan` muestra cambios no deseados, ajustas el bloque `resource` hasta que quede alineado con la infraestructura real.

## Diferencia entre `import` y `state rm`

- `terraform import` mete un recurso existente al estado
- `terraform state rm` saca un recurso del estado sin destruirlo

Son operaciones opuestas conceptualmente.

## Resumen

- `terraform import` sirve para empezar a gestionar recursos ya existentes
- no crea infraestructura
- registra el recurso en el estado
- despues del import debes alinear tu codigo `.tf` con el recurso real
- siempre conviene correr `terraform plan` justo despues
