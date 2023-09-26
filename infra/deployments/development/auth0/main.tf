variable "auth0_client_id" {
  description = "The client ID for the Auth0 'Terraform access' app for this environment"
  type        = string
  sensitive   = true
}

variable "auth0_client_secret" {
  description = "The client secret for the Auth0 'Terraform access' app for this environment"
  type        = string
  sensitive   = true
}

module "ses" {
  source = "../../../modules/ses"
}

module "auth0" {
  source = "../../../modules/auth0"

  admin_base_url    = "https://admin.dev.forms.service.gov.uk"
  env_name          = "dev"
  smtp_username     = module.ses.smtp_username
  smtp_password     = module.ses.smtp_password
  smtp_from_address = "no-reply@dev.forms.service.gov.uk"
}
