terraform {
  required_version = "= 1.2.8"

  required_providers {
    aws = ">= 4.37.0"
  }

  # Comment out when bootstrapping
  backend "s3" {
    bucket = "gds-forms-staging-tfstate"
    key    = "rds.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["972536609845"]

  default_tags {
    tags = {
      Environment = "staging"
      Deployment  = "staging/rds"
    }
  }
}


