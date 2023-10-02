module "users" {
  source = "../../../modules/users"
}

module "engineer_access" {
  source   = "../../../modules/engineer-access"
  admins   = module.users.with_role["deploy_admin"]
  support  = module.users.with_role["deploy_support"]
  readonly = module.users.with_role["deploy_readonly"]
  env_name = "deploy"
}
