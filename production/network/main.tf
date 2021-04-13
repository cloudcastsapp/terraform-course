terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.25.0"
    }
  }

  backend "s3" {
    profile = "cloudcasts"
    region  = "us-east-2"
  }
}

provider "aws" {
  profile = "cloudcasts"
  region  = "us-east-2"
}

variable "infra_env" {
  type        = string
  description = "infrastructure environment"
  default     = "production"
}

variable default_region {
  type = string
  description = "the region this infrastructure is in"
  default = "us-east-2"
}

module "vpc" {
  source = "../../modules/vpc"

  infra_env = var.infra_env
  vpc_cidr = "10.0.0.0/17"
  azs = ["us-east-2a", "us-east-2b", "us-east-2c"]
  public_subnets = slice(cidrsubnets("10.0.0.0/17", 4, 4, 4, 4, 4, 4, 4, 4, 4), 0, 3)
  private_subnets = slice(cidrsubnets("10.0.0.0/17", 4, 4, 4, 4, 4, 4, 4, 4, 4), 3, 6)
  database_subnets = slice(cidrsubnets("10.0.0.0/17", 4, 4, 4, 4, 4, 4, 4, 4, 4), 6, 9)
}
