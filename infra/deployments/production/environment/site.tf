terraform {
  required_version = "= 1.2.8"

  required_providers {
    aws = ">= 4.37.0"
  }

  backend "s3" {
    bucket = "gds-forms-production-tfstate"
    key    = "network.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["443944947292"]

  default_tags {
    tags = {
      Environment = "production"
      Deployment  = "production/environment"
    }
  }
}

provider "aws" {
  allowed_account_ids = ["443944947292"]

  region = "us-east-1"
  alias  = "us-east-1"

  default_tags {
    tags = {
      Environment = "production"
      Deployment  = "production/environment"
    }
  }
}


