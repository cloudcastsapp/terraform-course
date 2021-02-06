terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.25.0"
    }
  }
}

provider "aws" {
  profile = "cloudcasts"
  region  = "us-east-2"
}

variable infra_env {
  type = string
  description = "infrastructure environment"
}

variable default_region {
  type = string
  description = "the region this infrastructure is in"
  default = "us-east-2"
}

variable instance_size {
  type = string
  description = "ec2 web server size"
  default = "t3.small"
}


data "aws_ami" "app" {
  most_recent = true

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "tag:Component"
    values = ["app"]
  }

  filter {
    name   = "tag:Project"
    values = ["cloudcast"]
  }

  filter {
    name   = "tag:Environment"
    values = [var.infra_env]
  }

  owners = ["self"]
}

resource "aws_instance" "cloudcasts_web" {
  ami           = data.aws_ami.app.id
  instance_type = var.instance_size

  root_block_device {
    volume_size = 8 # GB
    volume_type = "gp3"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "cloudcasts-${var.infra_env}-web"
    Project     = "cloudcasts.io"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

resource "aws_eip" "app_eip" {
  vpc = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "cloudcasts-${var.infra_env}-web-address"
    Project     = "cloudcasts.io"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

resource "aws_eip_association" "app_eip_assoc" {
  instance_id   = aws_instance.cloudcasts_web.id
  allocation_id = aws_eip.app_eip.id
}