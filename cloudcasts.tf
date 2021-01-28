terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.25.0"
    }
  }
}

provider "aws" {
  profile = "cloudcasts"
  region = "us-east-2"
}