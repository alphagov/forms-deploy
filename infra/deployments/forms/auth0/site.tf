terraform {
  backend "s3" {
    # bucket set in backend config file
    key    = "auth0.tfstate"
    region = "eu-west-2"
  }
}

data "aws_ssm_parameter" "auth0_client_id" {
#   count = var.environmental_settings.disable_auth0 ? 0 : 1
  name  = "/terraform/auth0-access/client-id"
}

data "aws_ssm_parameter" "auth0_client_secret" {
#   count = var.environmental_settings.disable_auth0 ? 0 : 1
  name  = "/terraform/auth0-access/client-secret"
}

locals {
  auth0_client_id     = var.environmental_settings.disable_auth0 ? "" : data.aws_ssm_parameter.auth0_client_id.value
  auth0_client_secret = var.environmental_settings.disable_auth0 ? "" : data.aws_ssm_parameter.auth0_client_secret.value
}

provider "auth0" {
  domain = var.environmental_settings.auth0_domain

  client_id     = local.auth0_client_id
  client_secret = local.auth0_client_secret
}

provider "aws" {
  allowed_account_ids = var.allowed_account_ids

  default_tags {
    tags = merge(var.default_tags,
      {
        Deployment = "${var.environment_name}/auth0"
      }
    )
  }
}
