module "users" {
  source = "../../../modules/users"
}

module "engineer_access" {
  source                  = "../../../modules/engineer-access"
  admins                  = module.users.with_role["deploy_admin"]
  support                 = module.users.with_role["deploy_support"]
  readonly                = module.users.with_role["deploy_readonly"]
  env_name                = "deploy"
  codestar_connection_arn = var.codestar_connection_arn

  # Pentesters may not have GDS domains so our pattern using the 'users' module
  # doesn't necessarily work.
  pentesters = [
    "alice.carr@digital.cabinet-office.gov.uk",      # To help debugging if necessary.
    "andy.hunt@digital.cabinet-office.gov.uk",       # To help debugging if necessary.
    "catalina.garcia@digital.cabinet-office.gov.uk", # To help debugging if necessary.
  ]
}
