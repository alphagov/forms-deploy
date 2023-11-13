variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_product_page" {
  source             = "../../../modules/forms-product-page"
  env_name           = "dev"
  image_tag          = var.image_tag
  desired_task_count = 3
  cpu                = 256
  memory             = 512
  admin_base_url     = "https://admin.dev.forms.service.gov.uk"
}
