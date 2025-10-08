terraform {
  backend "s3" {
    # bucket set in backend config file
    key    = "network.tfstate"
    region = "eu-west-2"

    use_lockfile = true
  }
}

provider "aws" {
  allowed_account_ids = var.allowed_account_ids

  default_tags {
    tags = merge(var.default_tags,
      {
        Deployment = "${var.environment_name}/environment"
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
        Deployment = "${var.environment_name}/environment"
      }
    )
  }
}
