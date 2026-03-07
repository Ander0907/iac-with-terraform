variable "vpc_virginia_cidr" {
  description = "CIDR Virginia"
  type        = string
}

# variable "public_cidr_subnet" {
#   description = "CIDR Public Subnet"
#   type        = string
# }

# variable "private_cidr_subnet" {
#   description = "CIDR Private Subnet"
#   type        = string
# }

variable "subnets" {
  description = "List of Subnets"
  type        = list(string)
}

variable "tags" {
  description = "Project tags"
  type        = map(string)
}