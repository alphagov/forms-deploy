module "redis" {
  source   = "../../../modules/redis"
  env_name = "staging"
}

