variable "main_password" {
  type        = string
  sensitive   = true
  description = "The password for the database admin user"
}

module "rds" {
  source                   = "../../../modules/rds"
  env_name                 = "dev"
  main_password            = var.main_password
  auto_pause               = true
  seconds_until_auto_pause = 300
  apply_immediately        = true
}
