resource "aws_security_group" "rds" {
  name        = "forms-rds-${var.env_name}"
  description = "forms security group for rds in ${var.env_name}"
  vpc_id      = data.aws_vpc.forms.id

  tags = {
    Name = "forms-rds-${var.env_name}"
  }
}

resource "aws_security_group_rule" "rds_network_ingress" {
  type              = "ingress"
  from_port         = local.rds_port
  to_port           = local.rds_port
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.forms.cidr_block]
  security_group_id = aws_security_group.rds.id
}
