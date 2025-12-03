terraform {
  # Comment out when bootstrapping
  backend "s3" {
    bucket = "gds-forms-deploy-tfstate"
    key    = "pipeline_visualiser.tfstate"
    region = "eu-west-2"

    use_lockfile = true
  }
}

locals {
  deployment = "deploy/pipeline-visualiser"
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

provider "aws" {
  allowed_account_ids = [var.deploy_account_id]

  region = "us-east-1"
  alias  = "us-east-1"

  default_tags {
    tags = {
      Environment = "deploy"
      Deployment  = local.deployment
    }
  }
}
