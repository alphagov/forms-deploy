variable "apply_immediately" {
  type        = bool
  description = "Whether to apply change to the database immediately, or in the next maintenance window."
  default     = false
}

module "rds" {
  source   = "../../../modules/rds"
  env_name = var.environment_name

  apply_immediately        = var.apply_immediately
  rds_maintenance_window   = var.environmental_settings.rds_maintenance_window
  auto_pause               = var.environmental_settings.pause_databases_on_inactivity
  seconds_until_auto_pause = var.environmental_settings.pause_databases_after_inactivity_seconds
  backup_retention_period  = var.environmental_settings.database_backup_retention_period_days
}

data "aws_caller_identity" "current" {}

import {
  id = "/database/master-password"
  to = module.rds.aws_ssm_parameter.database_password_for_master_user
}

import {
  id = "/forms-admin-${var.environment_name}/database/password"
  to = module.rds.aws_ssm_parameter.database_password_for_forms_admin_app
}

import {
  id = "/forms-admin-${var.environment_name}/database/url"
  to = module.rds.aws_ssm_parameter.database_url_for_forms_admin_app
}

import {
  id = "/forms-api-${var.environment_name}/database/password"
  to = module.rds.aws_ssm_parameter.database_password_for_forms_api_app
}

import {
  id = "/forms-api-${var.environment_name}/database/url"
  to = module.rds.aws_ssm_parameter.database_url_for_forms_api_app
}