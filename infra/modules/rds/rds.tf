locals {
  rds_port            = 5432
  timestamp           = timestamp()
  timestamp_sanitized = replace("${local.timestamp}", "/[- TZ:]/", "")
}

resource "aws_rds_cluster_parameter_group" "aurora_postgres" {
  name_prefix = "forms-${var.env_name}"
  family      = "aurora-postgresql11"
  description = "RDS cluster parameter group for Aurora Serverless"

}

resource "aws_rds_cluster" "forms" {
  #checkov:skip=CKV_AWS_128:IAM auth to be considered: https://trello.com/c/nY2TcBXb/418-consider-rds-iam-auth
  #checkov:skip=CKV_AWS_162:Duplicate of CKV_AWS_128
  #checkov:skip=CKV2_AWS_8:AWS RDS inbuilt backup process is sufficient
  #checkov:skip=CKV2_AWS_27:Query logging is not required at this time
  #checkov:skip=CKV_AWS_133:Backup not required in all environments


  cluster_identifier = "aurora-cluster-${var.env_name}"

  availability_zones = var.availability_zones

  master_username = "root"
  master_password = var.main_password
  port            = local.rds_port

  engine         = "aurora-postgresql"
  engine_mode    = "serverless"
  engine_version = "11.13"

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds.id

  enable_http_endpoint = true

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_postgres.id

  apply_immediately = var.apply_immediately

  skip_final_snapshot       = false
  final_snapshot_identifier = "forms-${var.env_name}-${local.timestamp_sanitized}"
  copy_tags_to_snapshot     = true
  storage_encrypted         = true
  backup_retention_period   = var.backup_retention_period
  deletion_protection       = true

  scaling_configuration {
    auto_pause               = var.auto_pause
    max_capacity             = var.max_capacity
    min_capacity             = var.min_capacity
    seconds_until_auto_pause = var.seconds_until_auto_pause
    timeout_action           = "RollbackCapacityChange"
  }
}

