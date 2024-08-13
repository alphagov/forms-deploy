variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
  nullable    = true
  default     = null
}

module "forms_runner" {
  source                              = "../../../modules/forms-runner"
  env_name                            = var.environment_name
  root_domain                         = var.root_domain
  image_tag                           = var.image_tag
  cpu                                 = var.forms_runner_settings.cpu
  memory                              = var.forms_runner_settings.memory
  min_capacity                        = var.forms_runner_settings.min_capacity
  max_capacity                        = var.forms_runner_settings.max_capacity
  api_base_url                        = "https://api.${var.root_domain}"
  admin_base_url                      = "https://admin.${var.root_domain}"
  enable_maintenance_mode             = var.forms_runner_settings.enable_maintenance_mode
  cloudwatch_metrics_enabled          = var.forms_runner_settings.cloudwatch_metrics_enabled
  analytics_enabled                   = var.forms_runner_settings.analytics_enabled
  deploy_account_id                   = var.deploy_account_id
  csv_submission_enabled              = var.forms_runner_settings.csv_submission_enabled
  csv_submission_enabled_for_form_ids = var.forms_runner_settings.csv_submission_enabled_for_form_ids
}

import {
  id = "/forms-runner-${var.environment_name}/secret-key-base"
  to = module.forms_runner.aws_ssm_parameter.secret_key_base
}
