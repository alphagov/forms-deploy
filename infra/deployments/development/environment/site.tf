terraform {
  backend "s3" {
    bucket = "gds-forms-development-tfstate"
    key    = "network.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["498160065950"]

  default_tags {
    tags = {
      Environment = "development"
      Deployment  = "development/environment"
    }
  }
}

provider "aws" {
  allowed_account_ids = ["498160065950"]

  region = "us-east-1"
  alias  = "us-east-1"

  default_tags {
    tags = {
      Environment = "development"
      Deployment  = "development/environment"
    }
  }
}


