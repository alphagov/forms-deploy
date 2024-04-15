module "build-product-page-container" {
  source               = "../../../modules/image-builder-pipeline"
  application_name     = "forms-product-page"
  container_repository = "forms-product-page-deploy"
  source_repository    = "alphagov/forms-product-page"
}

module "build-forms-runner-container" {
  source               = "../../../modules/image-builder-pipeline"
  application_name     = "forms-runner"
  container_repository = "forms-runner-deploy"
  source_repository    = "alphagov/forms-runner"
}

module "build-forms-api-container" {
  source               = "../../../modules/image-builder-pipeline"
  application_name     = "forms-api"
  container_repository = "forms-api-deploy"
  source_repository    = "alphagov/forms-api"
}

module "build-forms-admin-container" {
  source               = "../../../modules/image-builder-pipeline"
  application_name     = "forms-admin"
  container_repository = "forms-admin-deploy"
  source_repository    = "alphagov/forms-admin"
}
