module "forms-admin" {
  source   = "../../../modules/main-branch-pipeline"
  app_name = "forms-admin"
}

module "forms-api" {
  source   = "../../../modules/main-branch-pipeline"
  app_name = "forms-api"
}

module "forms-runner" {
  source   = "../../../modules/main-branch-pipeline"
  app_name = "forms-runner"
}

module "forms-product-page" {
  source   = "../../../modules/main-branch-pipeline-no-smoke-tests"
  app_name = "forms-product-page"
}
