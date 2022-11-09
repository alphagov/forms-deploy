data "aws_vpc" "forms" {
  filter {
    name   = "tag:Name"
    values = ["forms-${var.env_name}"]
  }
}

data "aws_subnets" "private" {
  filter {
    name = "tag:Name"
    values = [
      "private-a-${var.env_name}",
      "private-b-${var.env_name}",
      "private-c-${var.env_name}"
    ]
  }
}

resource "aws_elasticache_subnet_group" "redis" {
  name        = "redis-${var.env_name}"
  description = "redis-${var.env_name} ElastiCache subnet group"
  subnet_ids  = data.aws_subnets.private.ids
}
