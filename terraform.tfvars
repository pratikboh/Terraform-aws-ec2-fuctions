aws_region         = "us-east-1"
vpc_cidr           = "172.18.0.0/16"
vpc_name           = "DevSecOps-fuction-Vpc"
azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]
environment        = "Prod"
key_name           = "SecOps-key"
public_cird_block  = ["172.18.1.0/24", "172.18.2.0/24", "172.18.3.0/24"]
private_cird_block = ["172.18.10.0/24", "172.18.20.0/24", "172.18.30.0/24"]
service_port       = ["22", "80", "8080", "443"]
amis = {
  us-east-1 = "ami-0866a3c8686eaeeba"
  us-east-2 = "ami-0ea3c35c5c3284d82"
}
