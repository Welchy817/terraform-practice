terraform {
  /*
  backend "remote" {
    organization = "mw-terraform-practice"

    workspaces {
      name = "provisioners"
    }
  }
  */
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.44.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "main" {
  id = ""     # Removed vpc id
}

resource "aws_security_group" "sg_my_server" {
  name        = "sg_my_server"
  description = "My Server Security Group"
  vpc_id      = data.aws_vpc.main.id

}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.sg_my_server.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.sg_my_server.id
  cidr_ipv4         = ""    # Removed public IP
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.sg_my_server.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = ""       # Removed key
}

data "template_file" "user_data" {
  template = file("./userdata.yaml")
}

resource "aws_instance" "my_server" {
    ami = "ami-051f8a213df8bc089"
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.deployer.key_name}"
    vpc_security_group_ids = [aws_security_group.sg_my_server.id]
    user_data = data.template_file.user_data.rendered
    # Local-exec
    /*
    provisioner "local-exec" {
      command = "echo ${self.private_ip} >> private_ips.txt"
    }
    */

    # Remote-exec
    /*
    provisioner "remote-exec" {
      inline = [
        "echo ${self.private_ip} >> /home/ec2-user/private_ips.txt"
      ]
      connection {
        type     = "ssh"
        user     = "ec2-user"
        host     = "${self.public_ip}"
        private_key = "${file("")}"   # Removed local file path
      }
    }
    */

    # File
    /*
    provisioner "file" {
      content = "mars"
      destination = "/home/ec2-user/barsoon.txt"
      connection {
        type     = "ssh"
        user     = "ec2-user"
        host     = "${self.public_ip}"
        private_key = "${file("~/.ssh/aws_terraform")}"
      }
    }
    */
    tags = {
        Name = "MyServer"
    }
}

resource "null_resource" "status" {
  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.my_server.id}"
  }
  depends_on = [aws_instance.my_server]
}

output "public_ip" {
  value = aws_instance.my_server.public_ip
}