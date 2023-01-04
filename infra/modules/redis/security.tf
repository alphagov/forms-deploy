resource "aws_security_group" "forms_runner_redis" {
  name        = "forms-runner-redis"
  description = "forms-runner redis security group"
  vpc_id      = data.aws_vpc.forms.id

  tags = {
    Name = "forms-runner-redis"
  }
}

resource "aws_security_group_rule" "redis_networks_ingress" {
  type              = "ingress"
  description       = "Permit inbound connections from within the VPC"
  from_port         = local.redis_port
  to_port           = local.redis_port
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.forms.cidr_block]
  security_group_id = aws_security_group.forms_runner_redis.id
}
