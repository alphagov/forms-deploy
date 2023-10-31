module "rds" {
  source                   = "../../../modules/rds"
  env_name                 = "user-research"
  auto_pause               = true
  seconds_until_auto_pause = 3600
  apply_immediately        = true

  backup_retention_period = 1
}
