terraform {
  backend "s3" {
    # bucket set in backend config file
    key    = "deployer_access.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = var.allowed_account_ids

  default_tags {
    tags = merge(var.default_tags.tags,
      {
        Deployment = "${var.environment_name}/deployer-access"
      }
    )
  }
}


