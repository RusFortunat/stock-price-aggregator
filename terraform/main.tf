terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }

  # TODO: Swap this for an S3+DynamoDB remote backend once you have a bucket (have to check the costs)
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      {
        Project     = var.project_name
        Environment = var.environment
        ManagedBy   = "terraform"
      },
      var.tags
    )
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}