terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.25.0"
    }
  }

  backend "s3" {
    bucket = "terraform-course-cloudcasts"
    key    = "cloudcasts/terraform.tfstate"
    profile = "cloudcasts"
    region  = "us-east-2"
    dynamodb_table = "cloudcasts-terraform-course"
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

module "ec2_app" {
  source = "./modules/ec2"

  infra_env = var.infra_env
  infra_role = "web"
  instance_size = "t3.small"
  instance_ami = data.aws_ami.app.id
  # instance_root_device_size = 12
  subnets = keys(module.vpc.vpc_public_subnets)
  security_groups = [module.vpc.security_group_public]
  tags = {
    Name = "cloudcasts-${var.infra_env}-web"
  }
  create_eip = true
}

module "ec2_worker" {
  source = "./modules/ec2"

  infra_env = var.infra_env
  infra_role = "worker"
  instance_size = "t3.large"
  instance_ami = data.aws_ami.app.id
  instance_root_device_size = 20
  subnets = keys(module.vpc.vpc_private_subnets)
  security_groups = [module.vpc.security_group_private]
  tags = {
    Name = "cloudcasts-${var.infra_env}-worker"
  }
  create_eip = false
}

module "vpc" {
  source = "./modules/vpc"

  infra_env = var.infra_env
  vpc_cidr = "10.0.0.0/17"
}
