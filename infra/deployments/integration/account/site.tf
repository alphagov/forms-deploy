terraform {
  backend "s3" {
    # bucket set in backend config
    key    = "account.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = [var.aws_account_id]
  default_tags {
    tags = {
      Deployment = "integration/account"
    }
  }
}
