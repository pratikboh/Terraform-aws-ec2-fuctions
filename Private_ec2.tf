resource "aws_instance" "private-server" {
  count                  = var.environment == "Prod" ? "${length(var.private_cird_block)}" : 1
  ami                    = lookup(var.amis, var.aws_region)
  instance_type          = "t2.micro"
  key_name               = "SecOps-Key"
  subnet_id              = element(aws_subnet.private-subnet.*.id, count.index)
  vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]

  tags = {
    Name  = "${var.vpc_name}-Private-Server-${count.index}"
    Env   = local.environment
    Owner = local.Owner
  }
  user_data = <<-EOF
      #!/bin/bash
      	sudo apt-get update
      	sudo apt-get install -y nginx
      	echo "<h1>${var.environment}-Server-${count.index}</h1>" | sudo tee /var/www/html/index.html
      	sudo systemctl start nginx
      	sudo systemctl enable nginx
      EOF
}
