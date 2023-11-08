variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_runner" {
  source                      = "../../../modules/forms-runner"
  env_name                    = "production"
  image_tag                   = var.image_tag
  desired_task_count          = 9
  cpu                         = 1024
  memory                      = 2048
  api_base_url                = "https://api.forms.service.gov.uk"
  admin_base_url              = "https://admin.forms.service.gov.uk"
  enable_maintenance_mode     = false
  email_confirmations_enabled = false
}
