variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_admin" {
  source             = "../../../modules/forms-admin"
  env_name           = "production"
  image_tag          = var.image_tag
  desired_task_count = 2
  cpu                = 256
  memory             = 512
  api_base_url       = "https://api.prod-temp.forms.service.gov.uk"    #TODO: Update for migration
  runner_base        = "https://submit.prod-temp.forms.service.gov.uk" #TODO: Update for migration
  govuk_app_domain   = "integration.publishing.service.gov.uk"         #TODO: Update for migration
  enable_draft_live_versions = true
  enable_basic_routing       = false
}
