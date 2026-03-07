## Dependencias implicitas vs explicitas en Terraform

Terraform construye un grafo de recursos para decidir el orden de creacion, actualizacion y destruccion.

## 1) Dependencia implicita

Existe cuando un recurso referencia directamente un atributo de otro recurso.
No necesitas `depends_on`.

```hcl
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.vpc_virginia.id
}

resource "aws_instance" "public_instance" {
  subnet_id = aws_subnet.public_subnet.id
}
```

Que significa:

- `aws_subnet.public_subnet` depende de `aws_vpc.vpc_virginia`
- `aws_instance.public_instance` depende de `aws_subnet.public_subnet`

Terraform infiere esto por las referencias:

- `aws_vpc.vpc_virginia.id`
- `aws_subnet.public_subnet.id`

## 2) Dependencia explicita (`depends_on`)

Se usa cuando NO hay una referencia directa entre recursos, pero igual necesitas forzar orden.

Ejemplo:

```hcl
resource "aws_security_group" "web_sg" {
  name   = "web-sg"
  vpc_id = aws_vpc.vpc_virginia.id
}

resource "aws_instance" "public_instance" {
  ami           = "ami-02dfbd4ff395f2a1b"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet.id

  depends_on = [aws_security_group.web_sg]
}
```

En este caso, aunque no estes usando `aws_security_group.web_sg.id` dentro de la instancia, Terraform espera a que el SG exista antes de crear la EC2.

## 3) Regla practica

- Usa primero dependencias implicitas (mas limpias y mantenibles).
- Usa `depends_on` solo cuando Terraform no pueda inferir el orden.
- Evita abusar de `depends_on`, porque hace el plan mas acoplado y mas lento.

## 4) Mini ejemplo de salida relacionada

Un `output` tambien crea dependencia implicita con lo que referencia:

```hcl
output "ec2_public_ip" {
  value = aws_instance.public_instance.public_ip
}
```

Terraform no puede resolver ese output hasta que exista `aws_instance.public_instance`.

