variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_admin" {
  source                  = "../../../modules/forms-admin"
  env_name                = "staging"
  image_tag               = var.image_tag
  desired_task_count      = 2
  cpu                     = 256
  memory                  = 512
  api_base_url            = "https://api.stage.forms.service.gov.uk"
  runner_base             = "https://submit.stage.forms.service.gov.uk"
  govuk_app_domain        = "integration.publishing.service.gov.uk"
  enable_maintenance_mode = false
  enable_basic_routing    = true
}
