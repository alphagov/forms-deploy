# We need to output or "expose" values from the elasticache.tf resource
# The only way we can expose the values is through outputs in a file
# at the same level as elasticache.tf
output "elasticache_primary_endpoint_address" {
  value = aws_elasticache_replication_group.forms-runner.primary_endpoint_address
}

output "elasticache_port" {
  value = aws_elasticache_replication_group.forms-runner.port
}