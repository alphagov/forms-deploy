terraform {
  backend "s3" {
    bucket = "gds-forms-staging-tfstate"
    key    = "network.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["972536609845"]

  default_tags {
    tags = {
      Environment = "staging"
      Deployment  = "staging/environment"
    }
  }
}

provider "aws" {
  allowed_account_ids = ["972536609845"]

  region = "us-east-1"
  alias  = "us-east-1"

  default_tags {
    tags = {
      Environment = "staging"
      Deployment  = "staging/environment"
    }
  }
}


