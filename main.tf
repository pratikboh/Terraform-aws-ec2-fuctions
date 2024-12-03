#This Terraform Code Deploys Basic VPC Infra.
provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "terraformpratik"
    key    = "Fuctions.statefile"
    region = "us-east-1"
    #dynamodb_table = "dynamodb-state-locking"
  }
}

resource "aws_vpc" "default" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name        = local.Name
    Owner       = local.Owner
    environment = local.environment
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "Fuctions-IGW"
  }
}

resource "aws_subnet" "public-subnet" {
  count             = length(var.public_cird_block)
  vpc_id            = aws_vpc.default.id
  cidr_block        = element(var.public_cird_block, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name        = "Public-subnet-${count.index}"
    Owner       = local.Owner
    environment = local.environment
  }
}

resource "aws_subnet" "private-subnet" {
  count             = length(var.private_cird_block)
  vpc_id            = aws_vpc.default.id
  cidr_block        = element(var.private_cird_block, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name        = "Private-subnet-${count.index}"
    Owner       = local.Owner
    environment = local.environment
  }
}


resource "aws_route_table" "RouteTable-public" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "RouteTable-public"
  }
}

resource "aws_route_table_association" "RouteTable-public" {
  count          = length(var.public_cird_block)
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.RouteTable-public.id
}

resource "aws_route_table" "RouteTable-private" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "RouteTable-private"
  }
}

resource "aws_route_table_association" "RouteTable-private" {
  count          = length(var.private_cird_block)
  subnet_id      = aws_subnet.private-subnet[count.index].id
  route_table_id = aws_route_table.RouteTable-private.id
}

resource "aws_security_group" "allow_all" {
  name        = "${var.vpc_name}-allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.default.id

  dynamic "ingress" {
    for_each = var.service_port
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  #  ingress {
  #    from_port   = 0
  #    to_port     = 0
  #    protocol    = "-1"
  #    cidr_blocks = ["0.0.0.0/0"]
  #  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# data "aws_ami" "my_ami" {
#      most_recent      = true
#      #name_regex       = "^sai"
#      owners           = ["232323232323232323"]
# }


# resource "aws_instance" "web-1" {
#     ami = "${data.aws_ami.my_ami.id}"
#     #ami = "ami-0d857ff0f5fc4e03b"
#     availability_zone = "us-east-1a"
#     instance_type = "t2.micro"
#     key_name = "LaptopKey"
#     subnet_id = "${aws_subnet.subnet1-public.id}"
#     vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
#     associate_public_ip_address = true	
#     tags = {
#         Name = "Server-1"
#         Env = "Prod"
#         Owner = "sai"
# 	CostCenter = "ABCD"
#     }
#      user_data = <<- EOF
#      #!/bin/bash
#      	sudo apt-get update
#      	sudo apt-get install -y nginx
#      	echo "<h1>${var.env}-Server-1</h1>" | sudo tee /var/www/html/index.html
#      	sudo systemctl start nginx
#      	sudo systemctl enable nginx
#      EOF

# }

# resource "aws_dynamodb_table" "state_locking" {
#   hash_key = "LockID"
#   name     = "dynamodb-state-locking"
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
#   billing_mode = "PAY_PER_REQUEST"
# }

##output "ami_id" {
#  value = "${data.aws_ami.my_ami.id}"
#}
#!/bin/bash
# echo "Listing the files in the repo."
# ls -al
# echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
# echo "Running Packer Now...!!"
# packer build -var=aws_access_key=AAAAAAAAAAAAAAAAAA -var=aws_secret_key=BBBBBBBBBBBBB packer.json
# echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
# echo "Running Terraform Now...!!"
# terraform init
# terraform apply --var-file terraform.tfvars -var="aws_access_key=AAAAAAAAAAAAAAAAAA" -var="aws_secret_key=BBBBBBBBBBBBB" --auto-approve
