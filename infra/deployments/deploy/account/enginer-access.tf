module "users" {
  source = "../../../modules/users"
}

module "engineer-access" {
  source = "../../../modules/engineer-access"

  env_name                            = "deploy"
  environment_type                    = "deploy"
  admins                              = module.users.with_role["deploy_admin"]
  support                             = module.users.with_role["deploy_support"]
  readonly                            = module.users.with_role["deploy_readonly"]
  vpn                                 = true
  codestar_connection_arn             = var.codestar_connection_arn
  dynamodb_state_file_locks_table_arn = null
  allow_rds_data_api_access           = false
  allow_ecs_task_usage                = false
}
