terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [ "amzn2-ami-kernel-5.10-hvm-2.0.20220606.1-x86_64-gp2" ]
  }
}

resource "aws_instance" "my_web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"


  user_data = <<-EOF
                #!/bin/bash
                sudo apt-get update
                sudo curl -fsSL https://get.docker.com/ | sh
                sudo systemctl restart docker
                cd ~/wordpress
                sudo docker run -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=wordpress --name wordpressdb -v "$PWD/database":/var/lib/mysql -d mariadb:latest
                sudo docker pull wordpress
                sudo docker run -e WORDPRESS_DB_USER=root -e WORDPRESS_DB_PASSWORD=password --name wordpress --link wordpressdb:mysql -p 80:80 -v "$PWD/html":/var/www/html -d wordpress
                EOF

  tags = {
    Name = "web_server"
  }
}