module "redis" {
  source                   = "../../../modules/redis"
  env_name                 = var.environment_name
  snapshot_retention_limit = var.environmental_settings.redis_backup_retention_period_days
}

