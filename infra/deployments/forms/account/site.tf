terraform {
  backend "s3" {
    bucket = "gds-forms-${var.environment_name}-tfstate"
    key    = "account.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = var.allowed_account_ids

  default_tags {
    tags = merge(var.default_tags.tags,
      {
        Deployment = "${var.environment_name}/account"
      }
    )
  }
}



