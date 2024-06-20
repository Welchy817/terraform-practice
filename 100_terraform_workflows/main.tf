terraform {

}

module "aws_server" {
    source = ".//terraform-aws-apache-example"
    instance_type = var.instance_type
    server_name = var.server_name
    public_key = var.public_key
    my_ip_with_cidr = var.my_ip_with_cidr
    vpc_id = var.vpc_id
}

provider "aws" {
  region = "us-east-1"
}

output "public_ip" {
    value = module.aws_server.public_ip
}