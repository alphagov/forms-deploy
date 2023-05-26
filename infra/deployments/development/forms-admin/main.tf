variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_admin" {
  source               = "../../../modules/forms-admin"
  env_name             = "dev"
  image_tag            = var.image_tag
  desired_task_count   = 1
  cpu                  = 256
  memory               = 512
  api_base_url         = "https://api.dev.forms.service.gov.uk"
  runner_base          = "https://submit.dev.forms.service.gov.uk"
  govuk_app_domain     = "integration.publishing.service.gov.uk"
  enable_basic_routing = true
}
