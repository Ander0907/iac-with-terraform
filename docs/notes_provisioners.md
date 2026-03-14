# Provisioners en Terraform

Los `provisioners` en Terraform permiten ejecutar acciones adicionales durante la creacion o destruccion de un recurso.

En otras palabras: Terraform crea la infraestructura y, justo despues, puede ejecutar comandos locales o remotos para completar alguna tarea operativa.

## Idea principal

Terraform esta pensado principalmente para **declarar infraestructura**. Los provisioners existen para resolver casos puntuales, pero HashiCorp recomienda usarlos **solo cuando no haya una mejor alternativa**.

Esto se debe a que:

- agregan pasos imperativos dentro de una herramienta declarativa
- pueden ser fragiles si dependen de red, SSH o tiempos de arranque
- hacen mas dificil depurar errores y mantener el codigo
- muchas veces pueden reemplazarse con `user_data`, imagenes AMI, cloud-init, pipelines o herramientas de configuracion como Ansible

## Tipos mas usados

Los provisioners que mas se usan en escenarios iniciales son:

- `local-exec`: ejecuta un comando en la maquina donde corre Terraform
- `remote-exec`: ejecuta comandos dentro del recurso remoto, normalmente por SSH o WinRM

## 1. `local-exec`

`local-exec` corre el comando **en tu equipo local** o en el runner donde se ejecuta Terraform, no dentro del servidor creado.

### Cuando sirve

- registrar informacion del recurso creado
- invocar un script local
- llamar una API externa
- generar un archivo de inventario
- disparar una validacion o automatizacion fuera de la VM

### Ejemplo basico

```hcl
resource "aws_instance" "public_instance" {
  ami                    = "ami-02dfbd4ff395f2a1b"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = data.aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.sg_public_instance.id]

  tags = {
    Name = "HelloWorld"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} >> public_ips.txt"
  }
}
```

### Que hace este ejemplo

Cuando Terraform crea la instancia, ejecuta localmente:

```bash
echo IP_PUBLICA >> public_ips.txt
```

Eso significa que el archivo `public_ips.txt` se guarda donde se esta ejecutando Terraform.

### Otro ejemplo util

```hcl
resource "aws_instance" "public_instance" {
  ami           = "ami-02dfbd4ff395f2a1b"
  instance_type = "t3.micro"

  provisioner "local-exec" {
    command = "curl -X POST https://example.com/webhook -d \"instance_id=${self.id}\""
  }
}
```

Caso de uso: notificar a otro sistema que una instancia fue creada.

## 2. `remote-exec`

`remote-exec` ejecuta comandos **dentro de la maquina remota** despues de que Terraform puede conectarse a ella.

Normalmente requiere:

- IP publica o conectividad hacia la instancia
- regla de seguridad que permita acceso
- llave SSH o credenciales adecuadas
- bloque `connection`

### Cuando sirve

- instalar paquetes rapidamente
- crear directorios o archivos de configuracion
- ejecutar comandos de bootstrap simples
- validar conectividad remota

### Ejemplo con SSH

```hcl
resource "aws_instance" "public_instance" {
  ami                    = "ami-02dfbd4ff395f2a1b"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = data.aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.sg_public_instance.id]

  tags = {
    Name = "HelloWorld"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("labsuser.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]
  }
}
```

### Que hace este ejemplo

Terraform:

1. crea la EC2
2. espera a poder conectarse por SSH
3. entra a la instancia
4. ejecuta los comandos definidos en `inline`

Esto ya ocurre **dentro del servidor**, no en tu maquina local.

## Diferencias entre `local-exec` y `remote-exec`

| Caracteristica | `local-exec` | `remote-exec` |
| --- | --- | --- |
| Donde corre | En la maquina que ejecuta Terraform | Dentro del recurso remoto |
| Requiere conexion SSH/WinRM | No | Si |
| Uso comun | Scripts locales, integraciones, logs, webhooks | Bootstrap inicial del servidor |
| Depende del estado del recurso remoto | Menos | Mucho mas |
| Fragilidad operativa | Media | Alta |

## `self` dentro de un provisioner

Dentro del bloque del provisioner se suele usar `self` para referirse al recurso actual.

Ejemplos:

- `self.id`
- `self.public_ip`
- `self.private_ip`

Ejemplo:

```hcl
provisioner "local-exec" {
  command = "echo Instancia creada: ${self.id}"
}
```

## Casos de uso reales

### Casos donde si puede tener sentido

- escribir la IP publica en un archivo local temporal
- registrar la creacion en un sistema externo
- ejecutar una inicializacion corta en una VM
- probar rapidamente laboratorios o entornos de aprendizaje

### Casos donde es mejor evitarlo

- instalar aplicaciones complejas
- manejar configuracion grande del sistema operativo
- aprovisionamiento repetible de muchos servidores
- procesos criticos que deban ser idempotentes y faciles de auditar

En esos casos suele ser mejor usar:

- `user_data`
- `cloud-init`
- AMIs preconfiguradas
- Packer
- Ansible
- pipelines CI/CD

## Provisioner al destruir recursos

Tambien existe la opcion de ejecutar provisioners durante la destruccion con `when = destroy`.

```hcl
resource "null_resource" "cleanup" {
  provisioner "local-exec" {
    when    = destroy
    command = "echo Recurso destruido"
  }
}
```

Esto puede servir para limpieza o notificaciones, aunque tambien debe usarse con cuidado.

## Manejo de errores

Por defecto, si el provisioner falla, Terraform marca error en la operacion.

Se puede controlar con `on_failure`.

```hcl
provisioner "local-exec" {
  command    = "echo intento de script"
  on_failure = continue
}
```

Opciones:

- `fail`: falla la ejecucion
- `continue`: continua aunque el provisioner falle

## `user_data`: una mejor alternativa para bootstrap

En AWS, `user_data` permite pasar un script a una instancia EC2 para que se ejecute durante su arranque inicial.

La idea es simple:

- Terraform crea la instancia
- AWS entrega el contenido de `user_data` a la maquina
- el sistema operativo lo ejecuta al iniciar, normalmente a traves de cloud-init

Eso significa que no necesitas que Terraform entre por SSH para configurar lo basico del servidor.

### Por que suele ser mejor que `remote-exec`

`user_data` suele ser mejor alternativa porque:

- no depende de que Terraform logre conectarse por SSH o WinRM
- reduce fragilidad por tiempos de espera, conectividad o llaves
- deja el bootstrap acoplado al ciclo de arranque de la instancia
- encaja mejor con el enfoque declarativo de infraestructura
- es mas facil de reutilizar en modulos, launch templates y autoscaling

### Diferencia conceptual

Con `remote-exec` el flujo es:

1. Terraform crea la instancia
2. Terraform espera conectividad
3. Terraform entra remotamente
4. Terraform ejecuta comandos

Con `user_data` el flujo es:

1. Terraform crea la instancia con un script embebido
2. la instancia arranca
3. cloud-init o el sistema ejecuta el script automaticamente

En resumen: `remote-exec` depende de una conexion remota posterior; `user_data` aprovecha el arranque natural de la instancia.

### Ejemplo con EC2

```hcl
resource "aws_instance" "public_instance" {
  ami                    = "ami-02dfbd4ff395f2a1b"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = data.aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.sg_public_instance.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl enable httpd
              systemctl start httpd
              echo "Servidor configurado con user_data" > /var/www/html/index.html
              EOF

  tags = {
    Name = "HelloWorld"
  }
}
```

### Que hace este ejemplo

Cuando la EC2 inicia por primera vez:

- actualiza paquetes
- instala Apache
- habilita el servicio
- inicia el servicio
- publica un `index.html`

Todo eso ocurre sin que Terraform tenga que abrir una sesion SSH.

### Cuando conviene usar `user_data`

- instalacion inicial de paquetes
- creacion de archivos de configuracion basicos
- habilitar y arrancar servicios
- preparar una instancia que debe quedar lista al boot
- laboratorios o despliegues simples en EC2

### Limitaciones de `user_data`

Aunque suele ser mejor que un provisioner, tampoco resuelve todo:

- normalmente esta pensado para configuracion inicial, no para gestion continua
- scripts muy largos se vuelven dificiles de mantener
- cambios en `user_data` pueden implicar recreacion o reinicio segun el recurso usado
- no reemplaza herramientas especializadas de configuracion para escenarios complejos

### `user_data` vs `remote-exec`

| Caracteristica | `user_data` | `remote-exec` |
| --- | --- | --- |
| Momento de ejecucion | Durante el arranque de la instancia | Despues de crear el recurso |
| Requiere SSH/WinRM desde Terraform | No | Si |
| Robustez | Mayor | Menor |
| Uso ideal | Bootstrap inicial | Tareas remotas puntuales |
| Escalabilidad | Mejor | Peor |

## Buenas practicas

- usa provisioners solo como ultimo recurso
- prefiere `user_data` o `cloud-init` para bootstrap de instancias
- evita scripts largos o complejos dentro de `remote-exec`
- manten los comandos simples, cortos e idempotentes
- no pongas secretos directamente en comandos si puedes evitarlos
- valida que el recurso tenga conectividad antes de depender de `remote-exec`

## Ejemplo recomendado para tu escenario

En tu laboratorio con una EC2 publica, `remote-exec` podria usarse para una instalacion rapida:

```hcl
resource "aws_instance" "public_instance" {
  ami                    = "ami-02dfbd4ff395f2a1b"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = data.aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.sg_public_instance.id]

  tags = {
    Name = "HelloWorld"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("labsuser.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Provisioning desde Terraform' | sudo tee /tmp/provisioner.txt",
      "sudo yum install -y httpd",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd"
    ]
  }
}
```

Y `local-exec` podria complementar para guardar la IP:

```hcl
provisioner "local-exec" {
  command = "echo ${self.public_ip} > instance_ip.txt"
}
```

## Resumen

- `local-exec` ejecuta comandos en la maquina local
- `remote-exec` ejecuta comandos dentro del recurso remoto
- ambos son utiles para tareas puntuales
- no deberian ser la primera opcion para configuracion compleja
- si necesitas automatizacion robusta, normalmente conviene usar otras herramientas o mecanismos nativos de arranque
