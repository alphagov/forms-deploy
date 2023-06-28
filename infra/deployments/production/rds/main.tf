variable "main_password" {
  type        = string
  sensitive   = true
  description = "The password for the database admin user"
}

module "rds" {
  source            = "../../../modules/rds"
  env_name          = "production"
  main_password     = var.main_password
  apply_immediately = true #TODO: consider whether applying out of hours in maintenance window might be better.
}
