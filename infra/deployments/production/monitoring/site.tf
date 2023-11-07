terraform {
  backend "s3" {
    bucket = "gds-forms-production-tfstate"
    key    = "monitoring.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["443944947292"]

  default_tags {
    tags = {
      Environment = "production"
      Deployment  = "production/monitoring"
    }
  }
}

