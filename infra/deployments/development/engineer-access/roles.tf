module "users" {
  source = "../../../modules/users"
}

module "engineer_access" {
  source   = "../../../modules/engineer-access"
  env_name = "dev"
  admins   = module.users.with_role["dev_admin"]
  support  = module.users.with_role["dev_support"]
  readonly = module.users.with_role["dev_readonly"]
  vpn      = false
}
