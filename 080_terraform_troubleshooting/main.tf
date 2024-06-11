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
  ami           = "ami-08a0d1e16fc3f61ea"
  instance_type = "t2.micro"
  tags = {
    Name = "MyServer"
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "my-new-bucket-120437912334453"
}

output "public_ip" {
    value = aws_instance.my_server[*].public_ip
}