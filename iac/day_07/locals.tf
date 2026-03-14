locals {
  sufix = "${var.tags.project}-${var.tags.env}-${var.tags.region}"
  s3_sufix = "${var.tags.project}-bucket-${random_string.s3-suffix.id}"
}

resource "random_string" "s3-suffix" {
  length  = 8
  upper   = false
  special = false
}