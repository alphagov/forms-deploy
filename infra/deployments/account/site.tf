terraform {
  backend "s3" {
    bucket = "gds-forms-${var.account_name}-tfstate"
    key    = "account.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = [var.aws_account_id]
}



