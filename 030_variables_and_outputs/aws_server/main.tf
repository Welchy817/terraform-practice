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
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

variable "instance_type"  {
    type = string
    description = "The size of the instance"
    #sensitive = true
    validation {
        condition = can(regex("^t2.", var.instance_type))
        error_message = "The instance must be a t2 type EC2 instance."
    }
}

# locals {
#   ami = "ami-051f8a213df8bc089"
#   instance_type = var.instance_type
# }

resource "aws_instance" "my_server" {
    ami           = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
}

output "public_ip" {
    value = aws_instance.my_server.public_ip
    #sensitive = true
}