module "rds" {
  source                   = "../../../modules/rds"
  env_name                 = "staging"
  auto_pause               = true
  seconds_until_auto_pause = 300
  apply_immediately        = true
}
