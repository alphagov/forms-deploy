module "users" {
  source = "../../../modules/users"
}

module "engineer_access" {
  source   = "../../../modules/engineer-access"
  env_name = var.environment_name
  admins   = module.users.with_role["${var.environment_type}_admin"]
  support  = module.users.with_role["${var.environment_type}_support"]
  readonly = module.users.with_role["${var.environment_type}_readonly"]
}
