terraform {
  required_version = "= 1.2.8"

  # Comment out when bootstrapping
  backend "s3" {
    bucket = "gds-forms-staging-tfstate"
    key    = "dns.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["972536609845"]

  default_tags {
    tags = {
      Environment = "staging"
      Deployment  = "staging/dns"
    }
  }
}

