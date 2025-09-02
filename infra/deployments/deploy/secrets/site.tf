terraform {
  # Comment out when bootstrapping
  backend "s3" {
    bucket = "gds-forms-deploy-tfstate"
    key    = "secrets.tfstate"
    region = "eu-west-2"

    use_lockfile = true
  }
}

provider "aws" {
  allowed_account_ids = [var.deploy_account_id]
  default_tags {
    tags = {
      Environment = "deploy"
      Deployment  = "deploy/secrets"
    }
  }
}
