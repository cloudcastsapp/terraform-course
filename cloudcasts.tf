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
    values = ["staging"]
  }

  owners = ["self"]
}

resource "aws_instance" "cloudcasts_web" {
  ami           = data.aws_ami.app.id
  instance_type = "t3.small"

  root_block_device {
    volume_size = 8 # GB
    volume_type = "gp3"
  }

  tags = {
    Name        = "cloudcasts-staging-web"
    Project     = "cloudcasts.io"
    Environment = "staging"
    ManagedBy   = "terraform"
  }
}

resource "aws_eip" "app_eip" {
  vpc = true

//  lifecycle {
//    prevent_destroy = true
//  }

  tags = {
    Name        = "cloudcasts-staging-web-address"
    Project     = "cloudcasts.io"
    Environment = "staging"
    ManagedBy   = "terraform"
  }
}

resource "aws_eip_association" "app_eip_assoc" {
  instance_id   = aws_instance.cloudcasts_web.id
  allocation_id = aws_eip.app_eip.id
}