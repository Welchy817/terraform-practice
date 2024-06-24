terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.44.0"
    }
  }
}

provider "aws" {
  # Configuration options
  profile = "default"
  region  = "us-east-1"
}

data "aws_ami" "packer_image" {
  most_recent = true
  owners = ["self"]
  filter {
    name = "name"
    values = ["my-server-httpd"]
  }
}

resource "aws_instance" "my_server" {
  count         = 2
  ami           = data.aws_ami.packer_image.id
  instance_type = "t2.micro"
  tags = {
    Name = "Server-Apache-Packer-${count.index}"
  }
}

output "public_ip" {
    value = aws_instance.my_server[*].public_ip
}