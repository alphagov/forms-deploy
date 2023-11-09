variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_api" {
  source    = "../../../modules/forms-api"
  env_name  = "production"
  image_tag = var.image_tag
  cpu       = 512
  memory    = 1024
}
