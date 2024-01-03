variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_product_page" {
  source         = "../../../modules/forms-product-page"
  env_name       = var.environment_name
  image_tag      = var.image_tag
  cpu            = var.forms_product_page_settings.cpu
  memory         = var.forms_product_page_settings.memory
  admin_base_url = "https://admin.${var.root_domain}"
  min_capacity   = var.forms_product_page_settings.min_capacity
  max_capacity   = var.forms_product_page_settings.max_capacity
}
