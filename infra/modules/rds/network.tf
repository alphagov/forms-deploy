resource "aws_db_subnet_group" "rds" {
  name        = "rds-${var.identifier}"
  description = "rds-${var.identifier} subnet group"
  subnet_ids  = var.subnet_ids
}
