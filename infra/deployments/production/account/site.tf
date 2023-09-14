terraform {
  required_version = "= 1.2.8"

  backend "s3" {
    bucket = "gds-forms-production-tfstate"
    key    = "account.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["443944947292"]

  default_tags {
    tags = {
      Environment = "production"
      Deployment  = "production/account"
    }
  }
}



