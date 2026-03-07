## Variables en Terraform

Puedes asignar valores a variables con variables de entorno usando el formato:

`TF_VAR_<nombre_variable>=<valor>`

Ejemplo:

`TF_VAR_region=us-east-1`

## Archivos de variables que Terraform carga automaticamente

Nombres validos:

- `terraform.tfvars`
- `terraform.tfvars.json`
- `*.auto.tfvars` (util para nombres personalizados)
- `*.auto.tfvars.json`

Ejemplo no cargado automaticamente:

- `proyecto.tfvars` (solo se usa si lo pasas con `-var-file`)

## Prioridad (precedencia) de valores de variables

De mayor a menor prioridad:

1. `-var` o `-var-file` (linea de comandos)
2. `*.auto.tfvars` y `*.auto.tfvars.json` (en orden alfabetico)
3. `terraform.tfvars` y `terraform.tfvars.json`
4. Variables de entorno (`TF_VAR_*`)
5. `default` definido en el bloque `variable`
