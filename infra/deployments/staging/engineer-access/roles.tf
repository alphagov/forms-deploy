module "users" {
  source = "../../../modules/users"
}

module "engineer_access" {
  source   = "../../../modules/engineer-access"
  env_name = "staging"
  admins   = module.users.with_role["staging_admin"]
  support  = module.users.with_role["staging_support"]
  readonly = module.users.with_role["staging_readonly"]
}
