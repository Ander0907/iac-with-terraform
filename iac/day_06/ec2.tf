resource "aws_instance" "public_instance" {
  ami                    = var.ec2_specs.ami
  instance_type          = var.ec2_specs.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = data.aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.sg_public_instance.id]
  user_data = file("scripts/userdata.sh")
  provisioner "local-exec" {
    command = "echo ${aws_instance.public_instance.public_ip} >> public_instance_ip.txt"
  }

  provisioner "local-exec" {
    when = destroy
    command = "echo ${self.public_ip} >> public_instance_ip.txt"
  }
  tags = {
    Name = "HelloWorld"
  }
}