module "users" {
  source = "../../../modules/users"
}

module "engineer_access" {
  source   = "../../../modules/engineer-access"
  env_name = "production"
  admins   = module.users.with_role["production_admin"]
  support  = module.users.with_role["production_support"]
  readonly = module.users.with_role["production_readonly"]
}
