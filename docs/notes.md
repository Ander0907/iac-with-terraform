## Variables en Terraform

Las variables permiten parametrizar tu configuracion sin cambiar el codigo.

## 1) Definicion de variables

Ejemplo en `variables.tf`:

```hcl
variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "demo"
}

variable "instance_count" {
  description = "Cantidad de instancias"
  type        = number
  default     = 1
}

variable "enable_monitoring" {
  description = "Habilita monitoreo"
  type        = bool
  default     = true
}

variable "db_password" {
  description = "Password de BD"
  type        = string
  sensitive   = true
}
```

## 2) Formas de asignar valores

### A. Variables de entorno

Formato:

`TF_VAR_<nombre_variable>=<valor>`

Ejemplo (PowerShell):

```powershell
$env:TF_VAR_project_name = "mi-app"
$env:TF_VAR_instance_count = "3"
```

### B. Archivo `terraform.tfvars`

Terraform lo carga automaticamente si el archivo se llama exactamente asi.

```hcl
project_name      = "app-prod"
instance_count    = 2
enable_monitoring = true
```

### C. Archivo personalizado con carga automatica

Archivos validos para autoload:

- `terraform.tfvars`
- `terraform.tfvars.json`
- `*.auto.tfvars`
- `*.auto.tfvars.json`

Ejemplo:

- `dev.auto.tfvars`
- `prod.auto.tfvars`

```hcl
# dev.auto.tfvars
project_name   = "app-dev"
instance_count = 1
```

### D. Archivo personalizado manual (`-var-file`)

Un archivo como `proyecto.tfvars` NO se carga automaticamente.
Debes pasarlo por linea de comandos:

```bash
terraform plan -var-file="proyecto.tfvars"
```

### E. Valor puntual con `-var`

```bash
terraform plan -var="project_name=app-qa" -var="instance_count=4"
```

## 3) Precedencia de variables (mayor a menor)

1. `-var` y `-var-file` en CLI
2. `*.auto.tfvars` y `*.auto.tfvars.json` (orden alfabetico)
3. `terraform.tfvars` y `terraform.tfvars.json`
4. Variables de entorno `TF_VAR_*`
5. `default` en el bloque `variable`

## 4) Tipos de variables

### Tipos basicos

- `string`: `"ejemplo"`
- `number`: `1`, `10.5`
- `bool`: `true` / `false`
- `any`: permite cualquier tipo (usar solo cuando no puedas tipar mejor)

## 5) Tipos complejos con ejemplos

### A. `list(T)`

Permite repetidos y mantiene orden.
Todos los elementos deben ser del mismo tipo.
Se accede por indice (`[0]`, `[1]`, ...).

```hcl
variable "allowed_ports" {
  type    = list(number)
  default = [80, 443, 8080]
}
```

Uso:

```hcl
from_port = var.allowed_ports[0]
```

### B. `map(T)`

Estructura clave-valor. Todas las values deben ser del mismo tipo.

```hcl
variable "tags" {
  type = map(string)
  default = {
    env   = "dev"
    owner = "platform"
  }
}
```

Uso:

```hcl
tags = var.tags
# var.tags["env"] => "dev"
```

### C. `set(T)`

No permite repetidos y no garantiza orden.
No es ideal para acceder por indice.

```hcl
variable "security_groups" {
  type    = set(string)
  default = ["sg-web", "sg-db"]
}
```

Uso:

```hcl
for_each = var.security_groups
```

### D. `object({...})`

Permite definir una estructura con campos de distintos tipos.

```hcl
variable "app_config" {
  type = object({
    name    = string
    replicas = number
    public  = bool
  })

  default = {
    name     = "api"
    replicas = 2
    public   = true
  }
}
```

Uso:

```hcl
name = var.app_config.name
```

### E. `tuple([...])`

Como una lista, pero con tipos fijos por posicion.

```hcl
variable "example_tuple" {
  type    = tuple([string, number, bool])
  default = ["api", 2, true]
}
```

### F. `output`

Sirve para exponer valores despues de `terraform apply` (por ejemplo IDs, IPs, URLs o nombres).

Ejemplo:

```hcl
output "instance_public_ip" {
  description = "IP publica de la instancia"
  value       = aws_instance.web.public_ip
}
```

Tambien puedes marcar un output como sensible:

```hcl
output "db_password" {
  value     = var.db_password
  sensitive = true
}
```

## 6) Nota sobre `sensitive`

Si una variable es `sensitive = true`, Terraform intenta ocultar su valor en la salida de `plan` y `apply`.
No reemplaza buenas practicas de secretos (Vault, SSM, Secret Manager, etc.).
