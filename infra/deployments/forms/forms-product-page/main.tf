variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
  nullable    = true
  default     = null
}

module "forms_product_page" {
  source            = "../../../modules/forms-product-page"
  env_name          = var.environment_name
  root_domain       = var.root_domain
  image_tag         = var.image_tag
  cpu               = var.forms_product_page_settings.cpu
  memory            = var.forms_product_page_settings.memory
  admin_base_url    = "https://admin.${var.root_domain}"
  min_capacity      = var.forms_product_page_settings.min_capacity
  max_capacity      = var.forms_product_page_settings.max_capacity
  deploy_account_id = var.deploy_account_id
}

import {
  id = "/forms-product-page-${var.environment_name}/secret-key-base"
  to = module.forms_product_page.aws_ssm_parameter.secret_key_base
}
