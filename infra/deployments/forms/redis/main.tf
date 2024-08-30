module "redis" {
  source                             = "../../../modules/redis"
  env_name                           = var.environment_name
  elasticache_replication_group_name = var.environment_name
}

