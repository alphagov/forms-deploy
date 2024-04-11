locals {
  rds_port            = 5432
  timestamp           = timestamp()
  timestamp_sanitized = replace("${local.timestamp}", "/[- TZ:]/", "")
}

data "aws_ssm_parameter" "database_password" {
  name = "/database/master-password"
}

resource "aws_rds_cluster_parameter_group" "aurora_postgres" {
  name_prefix = "forms-${var.env_name}"
  family      = "aurora-postgresql11"
  description = "RDS cluster parameter group for Aurora Serverless"
}

resource "aws_rds_cluster_parameter_group" "aurora_postgres_v13" {
  name_prefix = "forms-${var.env_name}-pg13"
  family      = "aurora-postgresql13"
  description = "RDS cluster parameter group for Aurora Serverless for PostgreSQL 13"
}

resource "aws_rds_cluster" "forms" {
  #checkov:skip=CKV_AWS_128:IAM auth to be considered: https://trello.com/c/nY2TcBXb/418-consider-rds-iam-auth
  #checkov:skip=CKV_AWS_162:Duplicate of CKV_AWS_128
  #checkov:skip=CKV2_AWS_8:AWS RDS inbuilt backup process is sufficient
  #checkov:skip=CKV2_AWS_27:Query logging is not required at this time
  #checkov:skip=CKV_AWS_133:Backup not required in all environments
  #checkov:skip=CKV_AWS_327:Database is already encrypted with the default key, and we feel this is sufficient
  #checkov:skip=CKV_AWS_324:Log capture is not required at this time


  cluster_identifier = "aurora-cluster-${var.env_name}"

  availability_zones = var.availability_zones

  master_username = "root"
  master_password = data.aws_ssm_parameter.database_password.value
  port            = local.rds_port

  engine         = "aurora-postgresql"
  engine_mode    = "serverless"
  engine_version = "13.12"

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds.id

  enable_http_endpoint = true

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_postgres_v13.id

  apply_immediately            = var.apply_immediately
  preferred_maintenance_window = var.rds_maintenance_window

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

  lifecycle {

    # Do not remove "restore_to_point_in_time" from this block unless you are trying
    # to create a new database from a point in time.
    #
    # We specified version 11.18 when we created the database clusters
    # but since then AWS have provided automatic minor version upgrdes.
    #
    # We don't wish for Terraform to attempt to downgrade the engine version,
    # or to have to update our config every time there's a new minor version.
    # Instead, we ignore any changes to the engine version, and allow AWS to
    # be the arbiter of the exact version.
    #
    # When we want to perform major version upgrades, we can remove this lifecycle
    # "engine_version" configuration, and replace it once the upgrade is complete.
    ignore_changes = [engine_version, db_cluster_parameter_group_name, restore_to_point_in_time]
  }
  allow_major_version_upgrade = true

  # Ensure resources that the cluster depends on are
  # handled before/after when creating/destroying
  depends_on = [
    aws_rds_cluster_parameter_group.aurora_postgres_v13
  ]

}

