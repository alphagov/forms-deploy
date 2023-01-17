module "redis" {
  source   = "../../../modules/redis"
  env_name = "user-research"

  #UR only needs single AZ.
  availability_zones         = ["eu-west-2a"]
  number_cache_clusters      = 1
  automatic_failover_enabled = false
  snapshot_retention_limit   = 0
}

