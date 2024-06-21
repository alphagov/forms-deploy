terraform {
  # Comment out when bootstrapping
  backend "s3" {
    # bucket set in backend config file
    key    = "health.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = var.allowed_account_ids

  default_tags {
    tags = merge(var.default_tags,
      {
        Deployment = "${var.environment_name}/health"
      }
    )
  }
}

provider "aws" {
  allowed_account_ids = var.allowed_account_ids

  region = "us-east-1"
  alias  = "us-east-1"

  default_tags {
    tags = merge(var.default_tags,
      {
        Deployment = "${var.environment_name}/health"
      }
    )
  }
}
