variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_product_page" {
  source             = "../../../modules/forms-product-page"
  env_name           = "production"
  image_tag          = var.image_tag
  desired_task_count = 2
  cpu                = 256
  memory             = 512
}
