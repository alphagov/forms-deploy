variable "main_password" {
  type        = string
  sensitive   = true
  description = "The password for the database admin user"
}

module "rds" {
  source                   = "../../../modules/rds"
  env_name                 = "user-research"
  main_password            = var.main_password
  auto_pause               = true
  seconds_until_auto_pause = 3600
  apply_immediately        = true

  backup_retention_period = 1
}
