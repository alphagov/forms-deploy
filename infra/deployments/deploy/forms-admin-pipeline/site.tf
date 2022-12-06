terraform {
  required_version = "= 1.2.8"

  required_providers {
    aws = ">= 4.37.0"
  }

  # Comment out when bootstrapping
  backend "s3" {
    bucket = "gds-forms-deploy-tfstate"
    key    = "forms-admin-pipeline.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["711966560482"]

  default_tags {
    tags = {
      Environment = "deploy"
      Deployment  = "deploy/forms-admin-pipeline"
    }
  }
}


