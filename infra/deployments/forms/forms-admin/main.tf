variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
  nullable    = true
  default     = null
}

module "forms_admin" {
  source                         = "../../../modules/forms-admin"
  env_name                       = var.environment_name
  root_domain                    = var.root_domain
  image_tag                      = var.image_tag
  cpu                            = var.forms_admin_settings.cpu
  memory                         = var.forms_admin_settings.memory
  min_capacity                   = var.forms_admin_settings.min_capacity
  max_capacity                   = var.forms_admin_settings.max_capacity
  api_base_url                   = "https://api.${var.root_domain}"
  runner_base                    = "https://submit.${var.root_domain}"
  govuk_app_domain               = var.forms_admin_settings.govuk_app_domain
  enable_maintenance_mode        = var.forms_admin_settings.enable_maintenance_mode
  forms_product_page_support_url = var.environmental_settings.forms_product_page_support_url
  auth_provider                  = var.forms_admin_settings.auth_provider
  previous_auth_provider         = var.forms_admin_settings.previous_auth_provider
  cloudwatch_metrics_enabled     = var.forms_admin_settings.cloudwatch_metrics_enabled
  analytics_enabled              = var.forms_admin_settings.analytics_enabled
  act_as_user_enabled            = var.forms_admin_settings.act_as_user_enabled
  enable_mailchimp_sync          = var.forms_admin_settings.synchronize_to_mailchimp
  deploy_account_id              = var.deploy_account_id
}

import {
  id = "/forms-admin-${var.environment_name}/secret-key-base"
  to = module.forms_admin.aws_ssm_parameter.secret_key_base
}
