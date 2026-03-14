resource "aws_s3_bucket" "name" {
  bucket = local.s3_sufix
}