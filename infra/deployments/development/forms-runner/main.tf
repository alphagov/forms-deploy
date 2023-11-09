variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
}

module "forms_runner" {
  source                      = "../../../modules/forms-runner"
  env_name                    = "dev"
  image_tag                   = var.image_tag
  cpu                         = 256
  memory                      = 512
  min_capacity                = 3
  max_capacity                = 3
  api_base_url                = "https://api.dev.forms.service.gov.uk"
  admin_base_url              = "https://admin.dev.forms.service.gov.uk"
  enable_maintenance_mode     = false
  email_confirmations_enabled = true
}
