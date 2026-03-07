resource "aws_instance" "public_instance" {
  ami           = "ami-02dfbd4ff395f2a1b"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet.id
  key_name = data.aws_key_pair.key.key_name
  tags = {
    Name = "HelloWorld"
  }
}