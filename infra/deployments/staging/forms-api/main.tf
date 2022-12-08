variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_api" {
  source             = "../../../modules/forms-api"
  env_name           = "staging"
  image_tag          = var.image_tag
  desired_task_count = 1
  cpu                = 256
  memory             = 512
}
