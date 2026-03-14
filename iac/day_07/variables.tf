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

variable "sg_ingress_cidr" {
  description = "CIDR for security group ingress rules"
  type        = string
}

variable "sg_egress_cidr" {
  description = "CIDR for security group egress rules"
  type        = string
}

variable "ec2_specs" {
  description = "AMI and Instance type for ECS"
  type = map(string)
}

variable "enabled_monitoring" {
  description = "Is enable monitoring"
  type = bool
}

variable "ingress_ports" {
  description = "List of ports to allow in security group ingress rules"
  type        = list(number)
}