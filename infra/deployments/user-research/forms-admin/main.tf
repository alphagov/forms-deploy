variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_admin" {
  source                      = "../../../modules/forms-admin"
  env_name                    = "user-research"
  image_tag                   = var.image_tag
  desired_task_count          = 1
  cpu                         = 256
  memory                      = 512
  api_base_url                = "https://api.research.forms.service.gov.uk"
  runner_base                 = "https://submit.research.forms.service.gov.uk"
  auth_provider               = "basic_auth"
  enable_maintenance_mode     = false
  maintenance_mode_bypass_ips = ""
}
