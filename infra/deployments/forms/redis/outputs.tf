# We need to "expose" the elasticache primary_endpoint_address and port through outputs
# This will populate the "outputs" section in the terraform state file for redis
# We have to apply the terraform in order for that outputs section in the state file to get populated
output "elasticache_primary_endpoint_address" {
  value = module.redis.elasticache_primary_endpoint_address
}

output "elasticache_port" {
  value = module.redis.elasticache_port
}