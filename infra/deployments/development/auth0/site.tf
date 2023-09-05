terraform {
  required_version = "= 1.2.8"

  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "= 1.0.0-beta.3"
    }
  }

  backend "s3" {
    bucket = "gds-forms-development-tfstate"
    key    = "auth0.tfstate"
    region = "eu-west-2"
  }
}
