resource "aws_vpc" "vpc_virginia" {
  cidr_block = var.vpc_virginia_cidr
  tags = {
    name = "My VPC"
    env  = "dev"
  }
}

resource "aws_vpc" "vpc_ohio" {
  cidr_block = var.vpc_ohio_cidr
  tags = {
    name = "My VPC"
    env  = "dev"
  }
  provider = aws.ohio
}
