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
  for_each = {
    nano  = "t2.nano"
    micro = "t2.micro"
    small = "t2.small"
  }
  ami           = "ami-051f8a213df8bc089"
  instance_type = each.value
  tags = {
    Name = "Server-${each.key}"
  }
}

output "public_ip" {
    value = values(aws_instance.my_server)[*].public_ip
}