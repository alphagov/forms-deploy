resource "aws_db_subnet_group" "rds" {
  name        = "rds-${var.env_name}"
  description = "rds-${var.env_name} subnet group"
  subnet_ids  = var.subnet_ids
}
