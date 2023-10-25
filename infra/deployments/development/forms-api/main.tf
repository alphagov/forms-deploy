variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_api" {
  source             = "../../../modules/forms-api"
  env_name           = "dev"
  image_tag          = var.image_tag
  desired_task_count = 6
  cpu                = 512
  memory             = 1024
}
