# Comandos de Terraform

## Flujo recomendado (dia a dia)
1. `terraform init`
2. `terraform fmt -recursive`
3. `terraform validate`
4. `terraform plan -out=tfplan`
5. `terraform apply tfplan`

## 1) `terraform init`
**Que hace:**
Inicializa el proyecto: descarga providers, configura backend y prepara el directorio de trabajo.

**Caso de uso:**
- Primera vez en un proyecto.
- Cambios en backend o providers.

**Ejemplo:**
```bash
terraform init
```

---

## 2) `terraform init -upgrade`
**Que hace:**
Reinicializa y actualiza providers/modulos a versiones mas nuevas (segun restricciones del codigo).

**Caso de uso:**
- Actualizar dependencias de Terraform.
- Probar una version mas reciente de un provider.

**Ejemplo:**
```bash
terraform init -upgrade
```

---

## 3) `terraform fmt`
**Que hace:**
Formatea archivos `.tf` con el estilo estandar de Terraform.

**Caso de uso:**
- Antes de commitear.
- Mantener formato consistente en equipo.

**Ejemplo:**
```bash
terraform fmt -recursive
```

---

## 4) `terraform validate`
**Que hace:**
Valida sintaxis y estructura de la configuracion.

**Caso de uso:**
- Revisar errores rapidos antes de `plan`.
- Integrarlo en CI/CD.

**Ejemplo:**
```bash
terraform validate
```

---

## 5) `terraform plan`
**Que hace:**
Muestra que cambios se van a crear, modificar o destruir, sin aplicarlos.

**Caso de uso:**
- Revisar impacto antes de `apply`.
- Revisiones tecnicas en PR.

**Ejemplo:**
```bash
terraform plan
```

---

## 6) `terraform plan -out=<archivo>`
**Que hace:**
Guarda el plan en un archivo binario para aplicarlo exactamente despues.

**Caso de uso:**
- Flujo con aprobacion (`plan -> revision -> apply`).
- Evitar diferencias entre lo planificado y lo aplicado.

**Ejemplo:**
```bash
terraform plan -out=tfplan
```

---

## 7) `terraform apply`
**Que hace:**
Aplica los cambios definidos por Terraform.

**Caso de uso:**
- Desplegar cambios luego de revisar `plan`.

**Ejemplo:**
```bash
terraform apply
```

---

## 8) `terraform apply tfplan`
**Que hace:**
Aplica exactamente el plan guardado en archivo.

**Caso de uso:**
- Pipelines con aprobacion manual.
- Entornos donde necesitas trazabilidad del cambio aplicado.

**Ejemplo:**
```bash
terraform apply tfplan
```

---

## 9) `terraform apply -auto-approve`
**Que hace:**
Aplica cambios sin pedir confirmacion interactiva.

**Caso de uso:**
- Automatizacion en CI/CD.
- Scripts no interactivos.

**Ejemplo:**
```bash
terraform apply -auto-approve
```

---

## 10) `terraform apply -target=<recurso>`
**Que hace:**
Aplica cambios solo a un recurso/modulo especifico.

**Caso de uso:**
- Recuperacion puntual.
- Diagnostico urgente y acotado.

**Nota:**
No es flujo normal; puede dejar cambios parciales y generar drift logico.

**Ejemplo:**
```bash
terraform apply -target=aws_instance.web
```

---

## 11) `terraform show`
**Que hace:**
Muestra informacion legible del estado o de un plan guardado.

**Caso de uso:**
- Inspeccionar recursos en estado.
- Revisar un `tfplan`.

**Ejemplos:**
```bash
terraform show
terraform show tfplan
```

---

## 12) `terraform output`
**Que hace:**
Imprime los valores de `output` definidos en la configuracion.

**Caso de uso:**
- Obtener IPs, IDs, URLs para scripts.
- Exponer datos entre etapas de despliegue.

**Ejemplos:**
```bash
terraform output
terraform output instance_ip
```

---

## 13) `terraform destroy`
**Que hace:**
Elimina toda la infraestructura gestionada por ese estado.

**Caso de uso:**
- Limpiar ambientes temporales.
- Reducir costos cuando ya no se necesita el entorno.

**Ejemplo:**
```bash
terraform destroy
```

---

## 14) `terraform providers`
**Que hace:**
Lista providers requeridos por la configuracion y por el estado.

**Caso de uso:**
- Auditar dependencias.
- Diagnosticar problemas de versiones/provider source.

**Ejemplo:**
```bash
terraform providers
```

---

## 15) `terraform graph`
**Que hace:**
Genera el grafo de dependencias entre recursos.

**Caso de uso:**
- Entender orden de creacion/destruccion.
- Analizar dependencias complejas.

**Ejemplo:**
```bash
terraform graph
```

---

## 16) `terraform state list`
**Que hace:**
Lista todos los recursos registrados en el estado.

**Caso de uso:**
- Ver inventario rapido de recursos gestionados.
- Preparar operaciones de `state mv` o `state rm`.

**Ejemplo:**
```bash
terraform state list
```

---

## 17) `terraform state show <recurso>`
**Que hace:**
Muestra los atributos de un recurso especifico en el estado.

**Caso de uso:**
- Depurar diferencias entre estado y configuracion.
- Ver IDs/atributos concretos de un recurso.

**Ejemplo:**
```bash
terraform state show aws_instance.web
```

---

## 18) `terraform state mv <origen> <destino>`
**Que hace:**
Mueve una direccion de recurso en el estado sin recrearlo.

**Caso de uso:**
- Refactor de nombres.
- Movimiento de recursos entre modulos.

**Ejemplo:**
```bash
terraform state mv aws_instance.web module.compute.aws_instance.web
```

---

## 19) `terraform state rm <recurso>`
**Que hace:**
Quita un recurso del estado sin destruirlo en el proveedor.

**Caso de uso:**
- Dejar de gestionar un recurso con Terraform.
- Reimportar un recurso con direccion diferente.

**Ejemplo:**
```bash
terraform state rm aws_instance.web
```

---

## 20) `terraform import <direccion> <id>`
**Que hace:**
Importa un recurso existente al estado de Terraform.

**Caso de uso:**
- Adoptar infraestructura creada fuera de Terraform.
- Recuperar estado despues de perdida parcial.

**Ejemplo:**
```bash
terraform import aws_instance.web i-0abc123def4567890
```

---

## 21) `terraform plan -refresh-only`
**Que hace:**
Compara estado y proveedor para detectar cambios externos sin proponer cambios de configuracion.

**Caso de uso:**
- Detectar drift.
- Auditoria de cambios hechos fuera de Terraform.

**Ejemplo:**
```bash
terraform plan -refresh-only
```

---

## Nota sobre `terraform refresh`
`terraform refresh` ya no es el flujo recomendado en versiones modernas.
Usa `terraform plan -refresh-only` o `terraform apply -refresh-only` segun el caso.

## Recomendaciones rapidas
- No edites `terraform.tfstate` manualmente.
- Prefiere backend remoto con locking.
- Evita `-target` salvo incidentes puntuales.
- En produccion, usa siempre `plan -out` y luego `apply <plan>`.

## 22) `terraform taint <recurso>`
**Que hace:**
Marca un recurso en el estado como "tainted" para forzar su recreacion en el siguiente `terraform apply`.

**Caso de uso:**
- El recurso quedo en mal estado y quieres recrearlo.
- Hubo una provision incompleta y conviene reemplazar la instancia.
- Laboratorios o pruebas donde quieres forzar recreacion puntual.

**Nota:**
Es un comando legado. En flujos modernos suele preferirse:

```bash
terraform apply -replace=aws_instance.web
```

porque permite revisar el cambio directamente en el plan/apply sin marcar el estado de forma separada.

**Ejemplo:**
```bash
terraform taint aws_instance.web
```

---

## 23) `terraform untaint <recurso>`
**Que hace:**
Quita la marca `tainted` de un recurso en el estado para evitar que Terraform lo recree automaticamente.

**Caso de uso:**
- Marcaste un recurso por error con `terraform taint`.
- Revisaste el recurso y confirmaste que no hace falta reemplazarlo.
- Quieres cancelar una recreacion forzada antes del siguiente `apply`.

**Ejemplo:**
```bash
terraform untaint aws_instance.web
```

**Flujo tipico:**
```bash
terraform taint aws_instance.web
terraform plan
terraform untaint aws_instance.web
```
