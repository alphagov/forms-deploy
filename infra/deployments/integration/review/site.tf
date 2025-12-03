terraform {
  # Comment out when bootstrapping
  backend "s3" {
    bucket = "gds-forms-integration-tfstate"
    key    = "review.tfstate"
    region = "eu-west-2"

    use_lockfile = true
  }
}

locals {
  deployment = "integration/review"
}

provider "aws" {
  allowed_account_ids = [var.aws_account_id]
  default_tags {
    tags = {
      Environment = "review"
      Deployment  = local.deployment
    }
  }
}

provider "aws" {
  allowed_account_ids = [var.aws_account_id]

  region = "us-east-1"
  alias  = "us-east-1"

  default_tags {
    tags = {
      Environment = "review"
      Deployment  = local.deployment
    }
  }
}
