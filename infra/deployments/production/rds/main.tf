module "rds" {
  source            = "../../../modules/rds"
  env_name          = "production"
  apply_immediately = true #TODO: consider whether applying out of hours in maintenance window might be better.
}
