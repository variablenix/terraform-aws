terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  profile = "default"
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::925717497924:role/terraform"
  }
}

