terraform {
  backend "s3" {
    bucket = "gds-forms-deploy-tfstate"
    key    = "account.tfstate"
    region = "eu-west-2"

    use_lockfile = true
  }
}

locals {
  deployment = "deploy/account"
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
