module "forms-admin-dev-pipeline" {
  source      = "../../../modules/development-branch-pipeline"
  app_name    = "forms-admin"
  environment = "dev"
}

module "forms-admin-user-research-pipeline" {
  source      = "../../../modules/development-branch-pipeline"
  app_name    = "forms-admin"
  environment = "user-research"
}
