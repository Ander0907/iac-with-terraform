# Terraform State (`tfstate`)

## Concepto rapido
Terraform compara:
1. Lo que defines en los archivos `.tf` (estado deseado).
2. Lo que esta registrado en `terraform.tfstate` (estado conocido/real).

Si ambos coinciden, `terraform plan` no mostrara cambios por aplicar.

## Archivos `.tf`
Los archivos `.tf` describen la infraestructura que quieres tener:
- Recursos
- Variables
- Providers
- Modulos

En resumen: representan el **estado deseado**.

## Archivo `terraform.tfstate`
El archivo `tfstate` guarda el mapeo entre la configuracion y los recursos reales creados en el proveedor cloud.

En resumen: representa el **estado actual conocido por Terraform**.

## Regla clave
**Nunca edites `terraform.tfstate` manualmente**, salvo casos muy controlados y con respaldo previo.

## Buenas practicas
- Usa un backend remoto (por ejemplo: S3 + DynamoDB, Azure Storage, GCS, Terraform Cloud).
- Protege el estado porque puede contener datos sensibles.
- Versiona solo los archivos `.tf`; evita commitear `terraform.tfstate` en Git.
- Usa bloqueo de estado para evitar conflictos cuando trabaja mas de una persona.
