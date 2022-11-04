terraform {
  required_version = "= 1.2.8"

  backend "s3" {
    bucket = "gds-forms-development-tfstate"
    key    = "dns.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["498160065950"]

  default_tags {
    tags = {
      Environment = "development"
      Deployment  = "development/dns"
    }
  }
}


