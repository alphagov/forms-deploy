module "users" {
  source = "../../modules/users"
}

module "engineer_access" {
  source                  = "../../modules/engineer-access"
  env_name                = var.account_name
  admins                  = module.users.with_role["${var.environment_type}_admin"]
  support                 = module.users.with_role["${var.environment_type}_support"]
  readonly                = module.users.with_role["${var.environment_type}_readonly"]
  vpn                     = var.require_vpn_to_access
  codestar_connection_arn = var.codestar_connection_arn
}
