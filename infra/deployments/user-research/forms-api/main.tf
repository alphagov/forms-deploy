variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_api" {
  #checkov:skip=CKV2_FORMS_AWS_2:We're OK with 2 instances in UR environment
  source             = "../../../modules/forms-api"
  env_name           = "user-research"
  image_tag          = var.image_tag
  desired_task_count = 2
  cpu                = 256
  memory             = 512
}
