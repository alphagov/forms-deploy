module "auth0" {
  source = "../../../modules/auth0"

  admin_base_url    = "https://admin.${var.root_domain}"
  env_name          = var.environment_name
  smtp_from_address = "no-reply@forms.service.gov.uk"

  allowed_email_domains = var.environmental_settings.allow_authentication_from_email_domains
}
