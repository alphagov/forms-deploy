variable "apply_immediately" {
  type        = bool
  description = "Whether to apply change to the database immediately, or in the next maintenance window."
  default     = false
}

module "rds" {
  source   = "../../../modules/rds"
  env_name = var.environment_name

  apply_immediately        = var.apply_immediately
  auto_pause               = var.environmental_settings.pause_databases_on_inactivity
  seconds_until_auto_pause = var.environmental_settings.pause_databases_after_inactivity_seconds
  backup_retention_period  = var.environmental_settings.database_backup_retention_period_days
}
