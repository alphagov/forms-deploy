module "forms-admin-dev-pipeline" {
  source      = "../../../modules/development-branch-pipeline"
  app_name    = "forms-admin"
  environment = "dev"
}

module "forms-api-dev-pipeline" {
  source      = "../../../modules/development-branch-pipeline"
  app_name    = "forms-api"
  environment = "dev"
}

module "forms-admin-user-research-pipeline" {
  source      = "../../../modules/development-branch-pipeline"
  app_name    = "forms-admin"
  environment = "user-research"
}

module "forms-api-user-research-pipeline" {
  source      = "../../../modules/development-branch-pipeline"
  app_name    = "forms-api"
  environment = "user-research"
}