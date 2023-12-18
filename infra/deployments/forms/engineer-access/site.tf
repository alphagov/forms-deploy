terraform {
  # Comment out when bootstrapping
  backend "s3" {
    bucket = "gds-forms-production-tfstate"
    key    = "engineers_access.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = var.allowed_account_ids

  default_tags {
    tags = merge(var.default_tags.tags,
      {
        Deployment = "${var.environment_name}/engineer-access"
      }
    )
  }
}


module "state_bucket" {
  source = "../../../modules/state-bucket"

  bucket_name = "gds-forms-production-tfstate"
}


