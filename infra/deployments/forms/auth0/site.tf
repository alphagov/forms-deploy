terraform {
  backend "s3" {
    # bucket set in backend config file
    key    = "auth0.tfstate"
    region = "eu-west-2"

    use_lockfile = true
  }
}

data "aws_ssm_parameter" "auth0_client_id" {
  count = var.environmental_settings.disable_auth0 ? 0 : 1
  name  = "/terraform/${var.environment_name}/auth0-access/client-id"
}

data "aws_ssm_parameter" "auth0_client_secret" {
  count = var.environmental_settings.disable_auth0 ? 0 : 1
  name  = "/terraform/${var.environment_name}/auth0-access/client-secret"
}

locals {
  # When Auth0 is disabled, we set these to dummy values to avoid provider errors.
  # The actual Auth0 resources will not be created because the module is not instantiated.
  auth0_domain        = var.environmental_settings.disable_auth0 ? "DISABLED_INVALID" : var.environmental_settings.auth0_domain
  auth0_client_id     = var.environmental_settings.disable_auth0 ? "DISABLED_INVALID" : data.aws_ssm_parameter.auth0_client_id[0].value
  auth0_client_secret = var.environmental_settings.disable_auth0 ? "DISABLED_INVALID" : data.aws_ssm_parameter.auth0_client_secret[0].value
}

provider "auth0" {
  domain = local.auth0_domain

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
