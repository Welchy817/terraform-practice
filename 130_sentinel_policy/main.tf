terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "5.44.0"
        }
    }
    cloud {
        organization = "mw-terraform-practice"

        workspaces {
            name = "mw-terraform-practice-sentinel"
        }
    }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "main" {
  id = ""
}

resource "aws_instance" "my_server" {
    ami = "ami-051f8a213df8bc089"
    instance_type = "t2.nano"
    tags = {
        Name = "MyServer"
    }
}

output "public_ip" {
  value = aws_instance.my_server.public_ip
}
