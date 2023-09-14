terraform {
  required_version = "= 1.2.8"

  required_providers {
    aws = ">= 4.37.0"
  }

  backend "s3" {
    bucket = "gds-forms-deploy-tfstate"
    key    = "account.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["711966560482"]

  default_tags {
    tags = {
      Environment = "deploy"
      Deployment  = "deploy/account"
    }
  }
}


