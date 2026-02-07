resource "aws_vpc" "mainvpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name        = "My VPC"
    Environment = "Dev"
  }
  provider = aws.ohio
}