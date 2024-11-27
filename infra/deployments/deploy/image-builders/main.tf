module "build-product-page-container" {
  source                  = "../../../modules/image-builder-pipeline"
  application_name        = "forms-product-page"
  container_repository    = "forms-product-page-deploy"
  source_repository       = "alphagov/forms-product-page"
  codestar_connection_arn = var.codestar_connection_arn
  ecr_repository_url      = data.terraform_remote_state.deploy_ecr.outputs.forms_product_page_ecr_repository_url

}

module "build-forms-runner-container" {
  source                  = "../../../modules/image-builder-pipeline"
  application_name        = "forms-runner"
  container_repository    = "forms-runner-deploy"
  source_repository       = "alphagov/forms-runner"
  codestar_connection_arn = var.codestar_connection_arn
  ecr_repository_url      = data.terraform_remote_state.deploy_ecr.outputs.forms_runner_ecr_repository_url
}

module "build-forms-api-container" {
  source                  = "../../../modules/image-builder-pipeline"
  application_name        = "forms-api"
  container_repository    = "forms-api-deploy"
  source_repository       = "alphagov/forms-api"
  codestar_connection_arn = var.codestar_connection_arn
  ecr_repository_url      = data.terraform_remote_state.deploy_ecr.outputs.forms_api_ecr_repository_url
}

module "build-forms-admin-container" {
  source                  = "../../../modules/image-builder-pipeline"
  application_name        = "forms-admin"
  container_repository    = "forms-admin-deploy"
  source_repository       = "alphagov/forms-admin"
  codestar_connection_arn = var.codestar_connection_arn
  ecr_repository_url      = data.terraform_remote_state.deploy_ecr.outputs.forms_admin_ecr_repository_url
}
