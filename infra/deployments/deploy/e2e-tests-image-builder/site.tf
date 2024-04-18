terraform {
  # Comment out when bootstrapping
  backend "s3" {
    bucket = "gds-forms-deploy-tfstate"
    key    = "e2e-tests-image-builder.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["711966560482"]

  default_tags {
    tags = {
      Environment = "deploy"
      Deployment  = "deploy/e2e-tests-image-builder"
    }
  }
}


