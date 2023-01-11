variable "main_password" {
  type        = string
  sensitive   = true
  description = "The password for the database admin user"
}

module "rds" {
  source                   = "../../../modules/rds"
  env_name                 = "production"
  main_password            = var.main_password
  auto_pause               = true #TODO: consider changing to false when live
  seconds_until_auto_pause = 300
  apply_immediately        = true #TODO: once set up we may want to change this to false
}
