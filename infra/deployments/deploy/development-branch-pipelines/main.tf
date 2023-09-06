module "forms-runner-dev-pipeline" {
  source      = "../../../modules/development-branch-pipeline"
  app_name    = "forms-runner"
  environment = "dev"
}

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

module "forms-product-page-dev-pipeline" {
  source        = "../../../modules/development-branch-pipeline"
  app_name      = "forms-product-page"
  environment   = "dev"
  source_branch = "main"
}

module "forms-runner-user-research-pipeline" {
  source      = "../../../modules/development-branch-pipeline"
  app_name    = "forms-runner"
  environment = "user-research"
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

module "forms-product-page-user-research-pipeline" {
  source        = "../../../modules/development-branch-pipeline"
  app_name      = "forms-product-page"
  environment   = "user-research"
  source_branch = "main"
}
