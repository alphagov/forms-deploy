locals {
  environments_with_e2e = ["dev", "staging", "production"]
}

module "forms-e2e-tests" {
  source                  = "../../../modules/e2e-image-pipeline"
  codestar_connection_arn = var.codestar_connection_arn
}

module "automated-test-parameters" {
  for_each = toset(local.environments_with_e2e)

  source           = "../../../modules/automated-test-parameters"
  environment_name = each.key
}
