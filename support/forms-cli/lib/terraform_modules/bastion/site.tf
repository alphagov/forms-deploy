terraform {
  backend "s3" {
    key    = "bastion.tfstate"
    region = "eu-west-2"

    use_lockfile = true
  }
}

provider "aws" {
  allowed_account_ids = [var.account_id]

  default_tags {
    tags = {
      Environment = "${var.environment}"
    }
  }
}
