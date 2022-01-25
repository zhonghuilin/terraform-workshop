terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.68.0"
    }
  }
}

provider "aws" {
  access_key = "AKIARLSHEJ4LMHIY5N7F"
  secret_key = "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"
  region = "us-east-1"
}

resource "aws_instance" "exercise_0000" {
  ami           = "ami-066157edddaec5e49"
  instance_type = "t2.micro"

  tags = {
    Name      = "exercise_0000"
    Terraform = true
  }
}
