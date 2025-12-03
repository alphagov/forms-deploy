terraform {
  # Comment out when bootstrapping
  backend "s3" {
    bucket = "gds-forms-deploy-tfstate"
    key    = "engineers_access.tfstate"
    region = "eu-west-2"

    use_lockfile = true
  }
}

locals {
  deployment = "deploy/engineer-access"
}

provider "aws" {
  allowed_account_ids = [var.deploy_account_id]
  default_tags {
    tags = {
      Environment = "deploy"
      Deployment  = local.deployment
    }
  }
}
module "state_bucket" {
  source = "../../../modules/state-bucket"

  bucket_name            = "gds-forms-deploy-tfstate"
  access_logging_enabled = true
}
