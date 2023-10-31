module "rds" {
  source                   = "../../../modules/rds"
  env_name                 = "dev"
  auto_pause               = false
  seconds_until_auto_pause = 300
  apply_immediately        = true
}
