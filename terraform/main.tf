
provider "aws" {
  region     = var.aws_region
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform-demo"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "app" {
  ami           = var.ami_id            
  instance_type = var.instance_type    
  key_name      = aws_key_pair.terraform_key.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker

    docker run -d --name app -p 80:80 bulakh/lab1bulakh:latest

    docker run -d \
      --name watchtower \
      -e WATCHTOWER_WATCHDOG=true \
      -v /var/run/docker.sock:/var/run/docker.sock \
      containrrr/watchtower --interval 30 my-site

  EOF

  tags = { Name = "terraform-demo-instance" }
}

output "instance_ip" {
  value = aws_instance.app.public_ip
}
