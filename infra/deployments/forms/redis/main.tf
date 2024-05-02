module "redis" {
  source   = "../../../modules/redis"
  env_name = var.environment_name
}

