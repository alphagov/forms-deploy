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

resource "aws_db_subnet_group" "rds" {
  name        = "rds-${var.env_name}"
  description = "rds-${var.env_name} subnet group"
  subnet_ids  = data.aws_subnets.private.ids
}
