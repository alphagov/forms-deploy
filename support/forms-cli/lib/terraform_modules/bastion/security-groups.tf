data "aws_security_groups" "database_security_groups" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name = "group-name"
    values = [
      for database in var.databases :
      "${database}*"
    ]
  }
}
