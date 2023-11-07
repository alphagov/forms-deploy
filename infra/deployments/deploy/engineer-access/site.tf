terraform {
  # Comment out when bootstrapping
  backend "s3" {
    bucket = "gds-forms-deploy-tfstate"
    key    = "engineers_access.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["711966560482"]
}

module "state_bucket" {
  source = "../../../modules/state-bucket"

  bucket_name = "gds-forms-deploy-tfstate"
}


