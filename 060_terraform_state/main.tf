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

resource "aws_instance" "my_server" {
  ami           = "ami-051f8a213df8bc089"
  instance_type = "t2.micro"
  tags = {
    Name = "MyServer"
  }
}

output "public_ip" {
    value = aws_instance.my_server[*].public_ip
}