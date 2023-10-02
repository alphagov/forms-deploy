terraform {
  backend "s3" {
    bucket = "gds-forms-development-tfstate"
    key    = "deployer_access.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["498160065950"]

  default_tags {
    tags = {
      Environment = "development"
      Deployment  = "development/deployer-access"
    }
  }
}



