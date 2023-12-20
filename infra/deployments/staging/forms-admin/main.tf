variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_admin" {
  source                         = "../../../modules/forms-admin"
  env_name                       = "staging"
  image_tag                      = var.image_tag
  cpu                            = 256
  memory                         = 512
  min_capacity                   = 3
  max_capacity                   = 3
  api_base_url                   = "https://api.staging.forms.service.gov.uk"
  runner_base                    = "https://submit.staging.forms.service.gov.uk"
  govuk_app_domain               = "staging.publishing.service.gov.uk"
  enable_maintenance_mode        = false
  metrics_feature_flag           = true
  forms_product_page_support_url = "https://www.staging.forms.service.gov.uk/support"
  auth_provider                  = "auth0"
  previous_auth_provider         = "gds_sso"
  cloudwatch_metrics_enabled     = true
  submission_email_changed_feature_flag = true
}
