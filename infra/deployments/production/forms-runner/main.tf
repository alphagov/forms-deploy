variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_runner" {
  source                      = "../../../modules/forms-runner"
  env_name                    = "production"
  image_tag                   = var.image_tag
  cpu                         = 1024
  memory                      = 2048
  min_capacity                = 6
  max_capacity                = 36
  api_base_url                = "https://api.forms.service.gov.uk"
  admin_base_url              = "https://admin.forms.service.gov.uk"
  enable_maintenance_mode     = false
  email_confirmations_enabled = false
  cloudwatch_metrics_enabled  = true
}
