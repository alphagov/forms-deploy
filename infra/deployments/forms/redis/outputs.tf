output "elasticache_primary_endpoint_address" {
  value = module.redis.elasticache_primary_endpoint_address
}

output "elasticache_port" {
  value = module.redis.elasticache_port
}
