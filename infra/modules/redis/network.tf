resource "aws_elasticache_subnet_group" "redis" {
  name        = "redis-${var.env_name}"
  description = "redis-${var.env_name} ElastiCache subnet group"
  subnet_ids  = var.subnet_ids
}
