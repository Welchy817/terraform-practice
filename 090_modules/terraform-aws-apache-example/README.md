Terraform Module to provision an EC2 Instance that is running Apache.

Not intended for production use. Just showcasing how to create a public module on Terraform Registry.

```hcl
terraform {

}

module "aws_server" {
    source = ".//terraform-aws-apache-example"
    instance_type = "t2.micro"
    server_name = "Apache-Example-Server"
    public_key = "ssh-rsa AAAA..."
    my_ip_with_cidr = "my_own_ip/32"
    vpc_id = "vpc-00000000000000000"
}

provider "aws" {
  region = "us-east-1"
}

output "public_ip" {
    value = module.aws_server.public_ip
}

```