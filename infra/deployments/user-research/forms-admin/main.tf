variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_admin" {
  source             = "../../../modules/forms-admin"
  env_name           = "user-research"
  image_tag          = var.image_tag
  desired_task_count = 1
  cpu                = 256
  memory             = 512
  api_base_url       = "https://api.research.forms.service.gov.uk"
  runner_base        = "https://submit.research.forms.service.gov.uk"
  govuk_app_domain   = "use_basic_auth" #TODO: Implement basic auth and remove this dummy value.
  enable_basic_auth  = true
  enable_basic_routing       = true
}
