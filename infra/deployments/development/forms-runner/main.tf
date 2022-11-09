variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_runner" {
  source             = "../../../modules/forms-runner"
  env_name           = "dev"
  image_tag          = var.image_tag
  desired_task_count = 1
  cpu                = 256
  memory             = 512
}
