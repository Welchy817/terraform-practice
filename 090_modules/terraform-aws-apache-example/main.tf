data "aws_vpc" "main" {
  id = var.vpc_id
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
  cidr_ipv4         = var.my_ip_with_cidr
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
  public_key = var.public_key
}

data "template_file" "user_data" {
  template = file("${abspath(path.module)}/userdata.yaml")
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name    = "owner-alias"
    values  = ["amazon"]
  }
  filter {
    name    = "name"
    values  = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "my_server" {
    ami = data.aws_ami.amazon-linux-2.id
    instance_type = var.instance_type
    key_name = "${aws_key_pair.deployer.key_name}"
    vpc_security_group_ids = [aws_security_group.sg_my_server.id]
    user_data = data.template_file.user_data.rendered
    tags = {
        Name = var.server_name
    }
}

output "public_ip" {
  value = aws_instance.my_server.public_ip
}
