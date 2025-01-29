resource "aws_security_group" "traefik" {
  #checkov:skip=CKV2_AWS_5:The security groups are attached in ecs.tf
  name        = "review-traefik"
  description = "Inbound and outbound traffic to Traefik"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "ingress_from_vpc" {
  description       = "Permit inbound form the VPC to the container port"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.cidr_block]
  security_group_id = aws_security_group.traefik.id
}

resource "aws_security_group_rule" "egress_to_vpc" {
  description       = "Permit outbound from the container to the VPC"
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.cidr_block]
  security_group_id = aws_security_group.traefik.id
}

resource "aws_security_group_rule" "egress_to_internet_via_tls" {
  description       = "Permit outbound from the container to the internet on port 443 (for retrieving Docker containers)"
  type              = "egress"
  from_port         = 0
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.traefik.id
}

resource "aws_security_group_rule" "ingress_to_traefik_healthcheck" {
  description       = "Permit inbound from the ALB to Traefik healthcheck endpoint"
  type              = "ingress"
  from_port         = 0
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = [var.cidr_block]
  security_group_id = aws_security_group.traefik.id
}