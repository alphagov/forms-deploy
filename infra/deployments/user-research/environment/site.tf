terraform {
  required_version = "= 1.2.8"

  required_providers {
    aws = ">= 4.37.0"
  }

  backend "s3" {
    bucket = "gds-forms-user-research-tfstate"
    key    = "network.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["619109835131"]

  default_tags {
    tags = {
      Environment = "user-research"
      Deployment  = "user-research/environment"
    }
  }
}


