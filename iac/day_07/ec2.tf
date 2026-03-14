variable "instances" {
  description = "Name of EC2 instances to create"
  type        = list(string)
  default     = ["instance1", "instance2", "instance3"]
}

resource "aws_instance" "public_instance" {
  for_each = toset(var.instances)
  ami                    = var.ec2_specs.ami
  instance_type          = var.ec2_specs.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = data.aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.sg_public_instance.id]
  user_data = file("scripts/userdata.sh")

  tags = {
    Name = "${each.value}-${local.sufix}"
  }
}

resource "aws_instance" "monitoring_instance" {
  count = var.enabled_monitoring ? 1 : 0
  ami                    = var.ec2_specs.ami
  instance_type          = var.ec2_specs.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = data.aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.sg_public_instance.id]
  user_data = file("scripts/userdata.sh")

  tags = {
    Name = "monitoring-${local.sufix}"
  }
}