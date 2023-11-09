variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_admin" {
  #checkov:skip=CKV2_FORMS_AWS_2:We're OK with 2 instances in UR environment
  source                           = "../../../modules/forms-admin"
  env_name                         = "user-research"
  image_tag                        = var.image_tag
  cpu                              = 256
  memory                           = 512
  min_capacity                     = 3
  max_capacity                     = 3
  api_base_url                     = "https://api.research.forms.service.gov.uk"
  runner_base                      = "https://submit.research.forms.service.gov.uk"
  auth_provider                    = "basic_auth"
  enable_maintenance_mode          = false
  metrics_feature_flag             = true
  email_confirmations_feature_flag = true
  forms_product_page_support_url   = "https://www.research.forms.service.gov.uk/support"
}
