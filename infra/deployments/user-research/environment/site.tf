terraform {
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

provider "aws" {
  allowed_account_ids = ["619109835131"]

  region = "us-east-1"
  alias  = "us-east-1"

  default_tags {
    tags = {
      Environment = "user-research"
      Deployment  = "user-research/environment"
    }
  }
}

