module "users" {
  source = "../../../modules/users"
}

module "engineer_access" {
  source                              = "../../../modules/engineer-access"
  admins                              = module.users.with_role["deploy_admin"]
  support                             = module.users.with_role["deploy_support"]
  readonly                            = module.users.with_role["deploy_readonly"]
  env_name                            = "deploy"
  environment_type                    = "deploy"
  codestar_connection_arn             = var.codestar_connection_arn
  dynamodb_state_file_locks_table_arn = "arn:aws:dynamodb::${var.deploy_account_id}:table/govuk-forms-deploy-tfstate-locking"
  allow_ecs_task_usage                = false
  allow_rds_data_api_access           = false

  # Pentesters may not have GDS domains so our pattern using the 'users' module
  # doesn't necessarily work.
  pentesters      = []
  pentester_cidrs = []
}
