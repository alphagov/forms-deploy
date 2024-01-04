variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_api" {
  source       = "../../../modules/forms-api"
  env_name     = var.environment_name
  image_tag    = var.image_tag
  cpu          = var.forms_api_settings.cpu
  memory       = var.forms_api_settings.memory
  min_capacity = var.forms_api_settings.min_capacity
  max_capacity = var.forms_api_settings.max_capacity
}
