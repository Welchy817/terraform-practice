terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.50.0"
    }
  }
}

provider "aws" {
  # Configuration options
  profile = "default"
  region = "us-east-1"
}

variable "hello" {
    type = string
}

variable "worlds" {
    type = list
}

variable "worlds_map" {
    type = map
}

variable "worlds_splat" {
    type = list
}

data "aws_vpc" "main" {
    id = "vpc-0324d8577ccf0ee98"
}

locals {
    ingress = [{
        port = 443
        description = "Port 443"
        ip_protocol = "tcp"
    },
    {
        port = 80
        description = "Port 80"
        ip_protocol = "tcp"
    }]
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.main.id

  dynamic "ingress" {
    for_each = local.ingress
    content {
      description       = ingress.value.description
      cidr_blocks       = [data.aws_vpc.main.cidr_block]
      from_port         = ingress.value.port
      protocol          = ingress.value.ip_protocol
      to_port           = ingress.value.port
      prefix_list_ids   = []
      security_groups   = []
      self = false
    }
  }

  egress = [
    {
      description      = "Outgoing for everyone"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
}