resource "aws_vpc" "vpc_virginia" {
  cidr_block = var.vpc_virginia_cidr
  tags = {
    name = "my VPC"
    env  = "dev"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc_virginia.id
  cidr_block = var.public_cidr_subnet
  # Allows instances launched in this subnet to receive a public IP address
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.vpc_virginia.id
  cidr_block = var.private_cidr_subnet
}