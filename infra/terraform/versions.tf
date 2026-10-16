terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
  }

  # Épico 2.1: backend remoto do estado (preencher após criar o bucket de state)
  # backend "s3" {
  #   bucket         = "<bucket-de-state>"
  #   key            = "aws-fundos-pipeline/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = var.project
      ManagedBy = "terraform"
    }
  }
}
