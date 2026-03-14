vpc_virginia_cidr = "10.10.0.0/16"
# public_cidr_subnet  = "10.10.1.0/24"
# private_cidr_subnet = "10.10.2.0/24"

subnets = [
  "10.10.1.0/24",
  "10.10.2.0/24"
]

tags = {
  "env"    = "dev"
  "ownwer" = "ander"
  "iac"    = "terraform"
}

sg_ingress_cidr = "0.0.0.0/0"
sg_egress_cidr  = "0.0.0.0/0"

ec2_specs = {
  ami           = "ami-02dfbd4ff395f2a1b"
  instance_type = "t3.micro"
}