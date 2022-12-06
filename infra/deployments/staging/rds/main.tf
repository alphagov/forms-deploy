variable "main_password" {
  type        = string
  sensitive   = true
  description = "The password for the database admin user"
}

module "rds" {
  source                   = "../../../modules/rds"
  env_name                 = "staging"
  main_password            = var.main_password
  deletion_protection      = false
  auto_pause               = true
  seconds_until_auto_pause = 300
  apply_immediately        = true
}
