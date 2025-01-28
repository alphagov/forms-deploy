resource "aws_security_group" "rds" {
  name        = "forms-rds-${var.identifier}"
  description = "forms security group for rds in ${var.env_name}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "forms-rds-${var.identifier}"
  }
}

resource "aws_security_group_rule" "rds_network_ingress" {
  type              = "ingress"
  description       = "Permit ingress from VPC CIDR"
  from_port         = local.rds_port
  to_port           = local.rds_port
  protocol          = "tcp"
  cidr_blocks       = var.ingress_cidr_blocks
  security_group_id = aws_security_group.rds.id
}
