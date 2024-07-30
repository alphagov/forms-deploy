terraform {
  # Comment out when bootstrapping
  backend "s3" {
    bucket = "gds-forms-deploy-tfstate"
    key    = "coordination.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = [var.deploy_account_id]
  default_tags {
    tags = {
      Environment = "deploy"
      Deployment  = "deploy/coordination"
    }
  }
}
