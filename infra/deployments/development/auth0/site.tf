terraform {
  required_version = "= 1.2.8"

  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.0.0"
    }

    aws = ">= 4.37.0"
  }

  backend "s3" {
    bucket = "gds-forms-development-tfstate"
    key    = "auth0.tfstate"
    region = "eu-west-2"
  }
}

data "aws_ssm_parameter" "auth0_client_id" {
  name = "/terraform/auth0-access/client-id"
}

data "aws_ssm_parameter" "auth0_client_secret" {
  name = "/terraform/auth0-access/client-secret"
}

provider "auth0" {
  domain = "govuk-forms-dev.uk.auth0.com"

  client_id     = data.aws_ssm_parameter.auth0_client_id.value
  client_secret = data.aws_ssm_parameter.auth0_client_secret.value
}

provider "aws" {
  allowed_account_ids = ["498160065950"]

  default_tags {
    tags = {
      Environment = "development"
      Deployment  = "development/auth0"
    }
  }
}
