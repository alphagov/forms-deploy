terraform {
  required_version = "= 1.2.8"

  # Comment out when bootstrapping
  backend "s3" {
    bucket = "gds-forms-user-research-tfstate"
    key    = "engineers_access.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["619109835131"]
}

module "state_bucket" {
  source = "../../../modules/state-bucket"

  bucket_name = "gds-forms-user-research-tfstate"
}


