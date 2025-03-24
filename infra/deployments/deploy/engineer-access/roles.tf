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
  pentesters = [
    "andy.hunt@digital.cabinet-office.gov.uk",    # To help debugging if necessary.
    "sarah.young1@digital.cabinet-office.gov.uk", # To help debugging if necessary.
    "nick.simpson@pentestpartners.com",
    "daniela.schoeffmann@pentestpartners.com",
    "james.palmer@pentestpartners.com",
  ]
  pentester_cidrs = [
    "212.38.169.64/27",
    "78.129.217.224/27",
    "91.238.238.0/25",
    "91.238.238.128/27",
    "91.238.238.160/27",
    "91.238.238.192/27"
  ]
}
