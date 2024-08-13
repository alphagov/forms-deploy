variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
  nullable    = true
  default     = null
}

module "forms_api" {
  source            = "../../../modules/forms-api"
  env_name          = var.environment_name
  root_domain       = var.root_domain
  image_tag         = var.image_tag
  cpu               = var.forms_api_settings.cpu
  memory            = var.forms_api_settings.memory
  min_capacity      = var.forms_api_settings.min_capacity
  max_capacity      = var.forms_api_settings.max_capacity
  deploy_account_id = var.deploy_account_id
}

import {
  id = "/forms-api-${var.environment_name}/secret-key-base"
  to = module.forms_api.aws_ssm_parameter.secret_key_base
}

import {
  id = "/forms-api-${var.environment_name}/sentry/dsn"
  to = module.forms_api.aws_ssm_parameter.sentry_dsn
}

import {
  id = "/forms-api-${var.environment_name}/forms-api-key"
  to = module.forms_api.aws_ssm_parameter.forms_api_key
}
