locals {
  redis_port = 6379
}

resource "aws_elasticache_replication_group" "forms-runner" {
  #checkov:skip=CKV_AWS_31:Password protection is not necessary
  #checkov:skip=CKV_AWS_191:AWS Managed SSE is sufficient.
  #checkov:skip=CKV2_AWS_50:Failover not required for all environments.

  replication_group_id       = "forms-runner-${var.env_name}"
  description                = "redis replication group for forms-runner"
  num_cache_clusters         = var.number_cache_clusters
  node_type                  = var.redis_node_type
  automatic_failover_enabled = var.automatic_failover_enabled
  availability_zones         = var.availability_zones
  engine                     = "redis"
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  engine_version             = var.engine_version
  port                       = local.redis_port
  parameter_group_name       = aws_elasticache_parameter_group.redis_parameter_group.id
  subnet_group_name          = aws_elasticache_subnet_group.redis.id
  security_group_ids         = [aws_security_group.forms_runner_redis.id]
  apply_immediately          = var.apply_immediately
  maintenance_window         = var.redis_maintenance_window
  snapshot_window            = var.redis_snapshot_window
  snapshot_retention_limit   = var.snapshot_retention_limit
  tags = {
    Name = "redis-${var.env_name}"
  }

  lifecycle {
    ignore_changes = [
      engine_version
    ]
  }
}

resource "aws_elasticache_parameter_group" "redis_parameter_group" {
  name        = "forms-runner-redis"
  description = "ElastiCache parameter group for redis cluster"
  family      = var.parameter_group_family
  dynamic "parameter" {
    for_each = var.redis_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
