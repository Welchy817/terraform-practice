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

resource "aws_s3_bucket" "my_bucket" {
    bucket = "mwelch-tf-test-depends-on-bucket"
    # depends_on = [
    #     aws_instance.my_server
    # ]
}

resource "aws_instance" "my_server" {
    ami           = "ami-051f8a213df8bc089"
    instance_type = "t2.micro"
    depends_on = [
        aws_s3_bucket.my_bucket
    ]
}

output "public_ip" {
    value = aws_instance.my_server.public_ip
}