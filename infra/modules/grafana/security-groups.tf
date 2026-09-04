data "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.region}.s3"
}

data "aws_prefix_list" "private_s3" {
  prefix_list_id = data.aws_vpc_endpoint.s3.prefix_list_id
}

resource "aws_security_group" "grafana" {
  #checkov:skip=CKV2_AWS_5:The security group is attached in ecs.tf
  name        = local.name
  description = "Ingress from VPC, egress to VPC, S3, the database and the internet"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "ingress_from_alb" {
  description              = "Permit inbound from the load balancer to the container port"
  type                     = "ingress"
  from_port                = local.container_port
  to_port                  = local.container_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.grafana.id
}

resource "aws_security_group_rule" "egress_to_s3_endpoint" {
  description       = "Permit outbound to the AWS S3 ip addresses"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = flatten(data.aws_prefix_list.private_s3.cidr_blocks)
  security_group_id = aws_security_group.grafana.id
}

resource "aws_security_group_rule" "egress_to_vpc_https" {
  description       = "Permit outbound to VPC CIDR on 443 for the VPC endpoints"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.grafana.id
}

resource "aws_security_group_rule" "egress_to_rds" {
  description              = "Permit outbound to the Grafana database"
  type                     = "egress"
  from_port                = local.rds_port
  to_port                  = local.rds_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds.id
  security_group_id        = aws_security_group.grafana.id
}

# GitHub (sign in), grafana.com (plugin install) and the CloudWatch, X-Ray,
# Athena and Glue APIs, none of which have VPC endpoints in this VPC.
resource "aws_security_group_rule" "egress_to_internet" {
  description       = "Permits outbound 443 to the internet"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.grafana.id
}
