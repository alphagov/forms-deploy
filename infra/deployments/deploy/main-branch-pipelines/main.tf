locals {
  environments_with_e2e = ["dev", "staging", "production"]
}
module "forms-admin" {
  source   = "../../../modules/main-branch-pipeline"
  app_name = "forms-admin"
}

module "forms-e2e-tests" {
  source = "../../../modules/e2e-image-pipeline"
}

module "automated-test-parameters" {
  for_each = toset(local.environments_with_e2e)

  source           = "../../../modules/automated-test-parameters"
  environment_name = each.key
}
