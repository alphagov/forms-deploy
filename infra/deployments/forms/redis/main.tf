module "redis" {
  source                             = "../../../modules/redis"
  env_name                           = var.environment_name
  elasticache_replication_group_name = data.terraform_remote_state.account.outputs.elasticache_replication_group_id
}

