terraform {
  backend "s3" {
    bucket = "gds-forms-staging-tfstate"
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
  domain = "govuk-forms-staging.uk.auth0.com"

  client_id     = data.aws_ssm_parameter.auth0_client_id.value
  client_secret = data.aws_ssm_parameter.auth0_client_secret.value
}

provider "aws" {
  allowed_account_ids = ["972536609845"]

  default_tags {
    tags = {
      Environment = "staging"
      Deployment  = "staging/auth0"
    }
  }
}
