module "users" {
  source = "../../../modules/users"
}

module "engineer_access" {
  source   = "../../../modules/engineer-access"
  env_name = "user-research"
  admins   = module.users.with_role["user_research_admin"]
  support  = module.users.with_role["user_research_support"]
  readonly = module.users.with_role["user_research_readonly"]
  vpn      = false
}
