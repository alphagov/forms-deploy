terraform {
  # Comment out when bootstrapping
  backend "s3" {
    bucket = "gds-forms-production-tfstate"
    key    = "forms_api.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["443944947292"]

  default_tags {
    tags = {
      Environment = "production"
      Deployment  = "production/forms-api"
    }
  }
}


