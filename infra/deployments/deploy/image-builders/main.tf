module "build-product-page-container" {
  source               = "../../../modules/image-builder-pipeline"
  application_name     = "forms-product-page"
  container_repository = "forms-product-page-deploy"
  source_repository    = "alphagov/forms-product-page"
}