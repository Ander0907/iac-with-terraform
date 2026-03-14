# Terraform Workspaces

Los `workspaces` en Terraform permiten usar la **misma configuracion** con **estados diferentes**.

La idea principal es esta:

- mantienes un mismo codigo Terraform
- cambias de workspace
- Terraform usa otro estado para ese workspace

Eso permite que una misma configuracion maneje contextos separados, por ejemplo:

- `default`
- `dev`
- `qa`
- `prod`

## Que es un workspace

Un workspace es una forma de separar el archivo de estado de Terraform dentro de una misma configuracion.

Cada workspace tiene su propio estado, lo que significa que Terraform puede gestionar recursos distintos aunque el codigo `.tf` sea el mismo.

## Idea simple

Supongamos que tienes este recurso:

```hcl
resource "aws_s3_bucket" "app" {
  bucket = "mi-bucket-app"
}
```

Si trabajas siempre en el workspace `default`, Terraform usa el estado de `default`.

Si cambias al workspace `dev`, Terraform pasa a usar el estado de `dev`.

Si luego cambias a `prod`, usara el estado de `prod`.

El codigo no cambia, pero el estado si.

## Para que sirven

Los workspaces sirven para aislar estados cuando quieres reutilizar la misma configuracion.

### Casos de uso comunes

- separar entornos simples como `dev` y `qa`
- hacer pruebas sin tocar el estado principal
- trabajar con la misma base Terraform para multiples variantes pequenas
- crear ambientes temporales para laboratorio

## Comandos principales

### Ver workspace actual

```bash
terraform workspace show
```

### Listar workspaces

```bash
terraform workspace list
```

### Crear un workspace

```bash
terraform workspace new dev
```

### Cambiar de workspace

```bash
terraform workspace select dev
```

### Eliminar un workspace

```bash
terraform workspace delete dev
```

## Workspace por defecto

Cuando inicializas un proyecto Terraform, existe un workspace llamado:

```bash
default
```

Ese es el workspace inicial.

Si nunca creas otros workspaces, siempre estaras trabajando ahi.

## Como funciona internamente

Cada workspace mantiene su propio estado.

Eso significa que:

- `dev` tiene un estado
- `qa` tiene otro
- `prod` tiene otro

En backend local, Terraform guarda esos estados en rutas separadas.

Con backend remoto, la forma exacta depende del backend, pero la idea sigue siendo la misma: cada workspace apunta a un estado distinto.

## Ejemplo de flujo

```bash
terraform init
terraform workspace new dev
terraform workspace select dev
terraform apply
terraform workspace new qa
terraform workspace select qa
terraform apply
```

Resultado:

- el mismo codigo
- dos workspaces distintos
- dos estados distintos
- potencialmente dos conjuntos de recursos distintos

## Usar el nombre del workspace en el codigo

Terraform expone el workspace actual mediante:

```hcl
terraform.workspace
```

Eso permite variar nombres o configuracion segun el workspace.

### Ejemplo

```hcl
resource "aws_s3_bucket" "app" {
  bucket = "mi-bucket-${terraform.workspace}"
}
```

Si estas en:

- `dev` -> crea `mi-bucket-dev`
- `prod` -> crea `mi-bucket-prod`

## Otro ejemplo practico

```hcl
resource "aws_instance" "web" {
  ami           = "ami-02dfbd4ff395f2a1b"
  instance_type = terraform.workspace == "prod" ? "t3.small" : "t3.micro"

  tags = {
    Environment = terraform.workspace
  }
}
```

En este caso:

- en `prod` usas una instancia mas grande
- en otros workspaces usas una mas pequena

## Casos donde si tienen sentido

- laboratorios o entornos de aprendizaje
- entornos simples y pequenos
- pruebas rapidas con el mismo codigo
- separacion ligera de estados dentro de un mismo proyecto

## Casos donde no son la mejor opcion

Aunque los workspaces son utiles, no siempre son la mejor estrategia para separar entornos.

### Evita depender solo de workspaces cuando:

- `prod` necesita controles mas estrictos
- cada entorno tiene configuraciones muy distintas
- necesitas permisos, backends o pipelines separados por entorno
- quieres aislamiento fuerte entre ambientes

En esos casos suele ser mejor:

- separar por carpetas
- separar por repositorios
- usar distintos backends
- usar modulos compartidos con roots distintos por entorno

## Diferencia entre workspaces y carpetas por entorno

Esta es una confusion muy comun.

### Con workspaces

- el codigo root es el mismo
- solo cambia el estado
- puedes usar `terraform.workspace` para pequenas variaciones

### Con carpetas separadas

- cada entorno puede tener su propia configuracion
- puedes usar variables, backends y permisos distintos
- hay mas aislamiento y control

## Regla practica

Usa workspaces cuando:

- los entornos son parecidos
- las diferencias son pequenas
- buscas rapidez y simplicidad

Prefiere separar entornos cuando:

- `prod` debe estar mucho mas controlado
- cambian cuentas, permisos, regiones o politicas
- el riesgo de error entre ambientes es alto

## Riesgos comunes

### 1. Creer que cambia la configuracion completa

El workspace cambia el estado, no automaticamente toda la arquitectura.

Si tu codigo no usa `terraform.workspace`, los recursos pueden intentar crearse igual en cada workspace.

### 2. Confundir entornos sensibles

Es facil olvidar en que workspace estas y aplicar cambios en el lugar equivocado.

Por eso conviene validar siempre:

```bash
terraform workspace show
```

### 3. Nombres duplicados

Si usas el mismo nombre de recurso real en varios workspaces, puedes tener colisiones.

Ejemplo:

- dos buckets S3 no pueden tener el mismo nombre global

Por eso suele ser necesario incluir `${terraform.workspace}` en nombres unicos.

## Buenas practicas

- ejecuta `terraform workspace show` antes de `plan` o `apply`
- usa nombres dependientes del workspace si el proveedor exige unicidad
- no uses workspaces como unica estrategia para aislar produccion critica
- documenta claramente que workspaces existen y para que sirve cada uno
- evita mezclar muchos comportamientos distintos en un mismo root module

## Ejemplo de uso recomendado

```hcl
resource "aws_s3_bucket" "logs" {
  bucket = "app-logs-${terraform.workspace}"

  tags = {
    Environment = terraform.workspace
  }
}
```

Esto funciona bien cuando:

- tienes mismo patron de infraestructura
- solo cambia el entorno
- necesitas nombres distintos por estado

## Resumen

- un workspace es una separacion de estado dentro de la misma configuracion
- permite reutilizar el mismo codigo con estados distintos
- `terraform.workspace` permite adaptar nombres o valores segun el entorno
- sirve bien en escenarios simples
- para produccion o entornos muy distintos, normalmente conviene separar mas fuerte la configuracion y el estado
