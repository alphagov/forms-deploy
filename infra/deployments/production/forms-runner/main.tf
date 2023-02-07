variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_runner" {
  source             = "../../../modules/forms-runner"
  env_name           = "production"
  image_tag          = var.image_tag
  desired_task_count = 2
  cpu                = 256
  memory             = 512
  api_base_url       = "https://api.prod-temp.forms.service.gov.uk" #TODO: update before migration
}
