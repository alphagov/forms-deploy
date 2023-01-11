variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_api" {
  source             = "../../../modules/forms-api"
  env_name           = "production"
  image_tag          = var.image_tag
  desired_task_count = 1 # TODO: Set this to at least 2 before go-live
  cpu                = 256
  memory             = 512
}
