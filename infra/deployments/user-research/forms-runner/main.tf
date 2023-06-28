variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_runner" {
  source                  = "../../../modules/forms-runner"
  env_name                = "user-research"
  image_tag               = var.image_tag
  desired_task_count      = 2
  cpu                     = 256
  memory                  = 512
  api_base_url            = "https://api.research.forms.service.gov.uk"
  admin_base_url          = "https://admin.research.forms.service.gov.uk"
  enable_maintenance_mode = false
}
