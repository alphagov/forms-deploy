terraform {
  # Comment out when bootstrapping
  backend "s3" {
    # bucket set in backend config file
    key    = "rds.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = var.allowed_account_ids

  default_tags {
    tags = merge(var.default_tags,
      {
        Deployment = "${var.environment_name}/rds"
      }
    )
  }
}

