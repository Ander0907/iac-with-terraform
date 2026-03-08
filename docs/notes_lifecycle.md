# Terraform `lifecycle`

## Que es `lifecycle`
En Terraform, `lifecycle` es un bloque dentro de un `resource` que te permite controlar **como Terraform crea, reemplaza, actualiza o protege** ese recurso.

No define la infraestructura en si, sino las **reglas de comportamiento** cuando hay cambios.

## Estructura base
```hcl
resource "aws_instance" "web" {
  ami           = "ami-1234567890abcdef0"
  instance_type = "t3.micro"

  lifecycle {
    create_before_destroy = true
  }
}
```

## Casos mas usados

## 1) `create_before_destroy`
Primero crea el nuevo recurso y despues destruye el anterior.

**Caso de uso:**
- Reducir downtime en recursos que requieren reemplazo.
- Migraciones donde no puedes quedarte sin servicio.

```hcl
lifecycle {
  create_before_destroy = true
}
```

## 2) `prevent_destroy`
Bloquea la destruccion del recurso aunque alguien ejecute `terraform destroy` o un cambio implique reemplazo.

**Caso de uso:**
- Bases de datos productivas.
- Recursos criticos o costosos de recuperar.

```hcl
lifecycle {
  prevent_destroy = true
}
```

## 3) `ignore_changes`
Le dice a Terraform que ignore cambios en ciertos atributos al comparar estado vs configuracion.

**Caso de uso:**
- Atributos gestionados por otro sistema.
- Tags dinamicos que cambian fuera de Terraform.

```hcl
lifecycle {
  ignore_changes = [
    tags,
    user_data
  ]
}
```

## 4) `replace_triggered_by`
Fuerza el reemplazo del recurso cuando cambia otro recurso/atributo relacionado.

**Caso de uso:**
- Recrear una instancia cuando cambia una plantilla, imagen o recurso dependiente.

```hcl
lifecycle {
  replace_triggered_by = [
    aws_launch_template.app.id
  ]
}
```

## Ejemplo completo
```hcl
resource "aws_db_instance" "main" {
  identifier        = "app-db-prod"
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  lifecycle {
    prevent_destroy       = true
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}
```

## Buenas practicas
- Usa `prevent_destroy` solo en recursos realmente criticos, porque tambien puede bloquear cambios legitimos.
- Usa `ignore_changes` con precision; ignorar demasiados atributos puede ocultar drift.
- Prueba siempre con `terraform plan` antes de `apply` para entender el impacto de `lifecycle`.
- Documenta en comentarios por que aplicaste cada regla.

## Errores comunes
- Usar `ignore_changes = all` sin entender consecuencias.
- Confiar en `create_before_destroy` cuando el proveedor no permite dos recursos equivalentes al mismo tiempo.
- Activar `prevent_destroy` y olvidar que impedira reemplazos futuros.

## Resumen rapido
`lifecycle` te da control fino sobre el comportamiento operativo de Terraform. Es clave para proteger recursos criticos, reducir downtime y manejar cambios complejos de forma segura.
