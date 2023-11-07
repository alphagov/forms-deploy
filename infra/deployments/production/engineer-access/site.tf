terraform {
  # Comment out when bootstrapping
  backend "s3" {
    bucket = "gds-forms-production-tfstate"
    key    = "engineers_access.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["443944947292"]
}

module "state_bucket" {
  source = "../../../modules/state-bucket"

  bucket_name = "gds-forms-production-tfstate"
}


