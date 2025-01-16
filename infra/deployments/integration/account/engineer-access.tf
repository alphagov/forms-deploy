module "users" {
  source = "../../../modules/users"
}

module "engineer_access" {
  source                              = "../../../modules/engineer-access"
  admins                              = module.users.with_role["integration_admin"]
  support                             = module.users.with_role["integration_support"]
  readonly                            = module.users.with_role["integration_readonly"]
  env_name                            = "integration"
  environment_type                    = "integration"
  codestar_connection_arn             = var.codestar_connection_arn
  dynamodb_state_file_locks_table_arn = "arn:aws:dynamodb::${var.aws_account_id}:table/govuk-forms-integration-tfstate-locking"
  allow_ecs_task_usage                = false
  allow_rds_data_api_access           = false

  # Pentesters may not have GDS domains so our pattern using the 'users' module
  # doesn't necessarily work.
  pentesters = []
}
