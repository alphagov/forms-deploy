terraform {
  # Comment out when bootstrapping
  backend "s3" {
    bucket = "gds-forms-staging-tfstate"
    key    = "engineers_access.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["972536609845"]
}

module "state_bucket" {
  source = "../../../modules/state-bucket"

  bucket_name = "gds-forms-staging-tfstate"
}


