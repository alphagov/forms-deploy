data "aws_vpc" "forms" {
  filter {
    name   = "tag:Name"
    values = ["forms-${var.env_name}"]
  }
}

data "aws_vpc_endpoint" "s3" {
  vpc_id       = data.aws_vpc.forms.id
  service_name = "com.amazonaws.eu-west-2.s3"
}

data "aws_prefix_list" "private_s3" {
  prefix_list_id = data.aws_vpc_endpoint.s3.prefix_list_id
}

resource "aws_security_group" "baseline" {
  name        = "forms-baseline-${var.env_name}"
  description = "Ingress from VPC, egress to VPC and S3"
  vpc_id      = data.aws_vpc.forms.id
}

resource "aws_security_group_rule" "ingress_from_vpc" {
  description       = "permit inbound form the VPC to the container port"
  type              = "ingress"
  from_port         = var.container_port
  to_port           = var.container_port
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.forms.cidr_block]
  security_group_id = aws_security_group.baseline.id
}

resource "aws_security_group_rule" "egress_to_s3_endpoint" {
  description       = "permit outbound to the AWS S3 ip addresses"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = flatten(data.aws_prefix_list.private_s3.cidr_blocks)
  security_group_id = aws_security_group.baseline.id
}

resource "aws_security_group_rule" "egress_to_vpc" {
  description       = "Permit outbound to VPC CIDR on 443"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.forms.cidr_block]
  security_group_id = aws_security_group.baseline.id
}

resource "aws_security_group_rule" "egress_to_redis" {
  description       = "Permit outbound to the redis port 6379"
  type              = "egress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.forms.cidr_block]
  security_group_id = aws_security_group.baseline.id
}

resource "aws_security_group_rule" "egress_to_internet" {
  count = var.permit_internet_egress ? 1 : 0

  description       = "Permits outbound 443 to the internet"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.baseline.id
}
