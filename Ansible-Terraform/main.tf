##############################
# Demo Nginx Server
##############################

locals {
  project_tag = "Understand Ansible Terraform"
}

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
  region = "us-east-2"
}


# ssh key for accessing the server
resource "aws_key_pair" "nginx_key_pair" {
  key_name_prefix = "uta-nginx-"
  public_key      = var.ssh_pub_key

  tags = {
    Project = local.project_tag
  }
}


# the server itself
resource "aws_instance" "nginx_proxy" {
  ami                         = var.nginx_ami
  instance_type               = var.nginx_instance_size
  key_name                    = aws_key_pair.nginx_key_pair.key_name
  associate_public_ip_address = true
  security_groups             = [aws_security_group.nginx_sg.name]

  # execute ansible playbooks
  provisioner "local-exec" {
    # use current public ip because eip is not associated yet
    command = "ansible-playbook -u ubuntu -i '${self.public_ip},' --private-key ${var.ssh_priv_key_path} ${path.module}/playbooks/nginx_server.yaml"
  }

  tags = {
    Name    = "Nginx Demo Server"
    Project = local.project_tag
  }
}


# allow incoming/outgoing connections to nginx server
resource "aws_security_group" "nginx_sg" {
  name        = "uta-nginx-sg"
  description = "Allow Ansible and Web Traffic"

  ingress {
    description = "SSH from Whitelist"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.mgmt_whitelist
  }

  ingress {
    description = "Allow all tcp to port 8000"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound!"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = local.project_tag
    Env     = "Test"
  }
}
