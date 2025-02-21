output "elasticache_primary_endpoint_address" {
  value = aws_elasticache_replication_group.forms_runner.primary_endpoint_address
}

output "elasticache_port" {
  value = aws_elasticache_replication_group.forms_runner.port
}