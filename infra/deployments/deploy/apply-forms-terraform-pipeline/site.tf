terraform {
  # Comment out when bootstrapping
  backend "s3" {
    # key is set by a back end config
    bucket = "gds-forms-deploy-tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["711966560482"]

  default_tags {
    tags = {
      Environment = "deploy"
      Deployment  = "deploy/apply-forms-terraform-pipeline"
    }
  }
}


