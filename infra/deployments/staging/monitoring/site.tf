terraform {
  required_version = "= 1.2.8"

  required_providers {
    aws = ">= 4.37.0"
  }

  backend "s3" {
    bucket = "gds-forms-staging-tfstate"
    key    = "monitoring.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["97253660984"]

  default_tags {
    tags = {
      Environment = "staging"
      Deployment  = "staging/monitoring"
    }
  }
}

