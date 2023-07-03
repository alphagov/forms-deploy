variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_admin" {
  source                      = "../../../modules/forms-admin"
  env_name                    = "production"
  image_tag                   = var.image_tag
  desired_task_count          = 3
  cpu                         = 256
  memory                      = 512
  api_base_url                = "https://api.forms.service.gov.uk"
  runner_base                 = "https://submit.forms.service.gov.uk"
  govuk_app_domain            = "publishing.service.gov.uk"
  enable_maintenance_mode     = true
  secret_kind                 = "perm/"
}
