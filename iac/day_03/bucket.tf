terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "providers" {
  bucket = "bkt-terraform-aws-practicioner-dev"
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}