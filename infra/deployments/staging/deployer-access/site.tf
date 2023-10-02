terraform {
  backend "s3" {
    bucket = "gds-forms-staging-tfstate"
    key    = "deployer_access.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["972536609845"]

  default_tags {
    tags = {
      Environment = "staging"
      Deployment  = "staging/deployer-access"
    }
  }
}



