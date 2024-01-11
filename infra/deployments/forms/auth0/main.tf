module "auth0" {
  count  = var.environmental_settings.disable_auth0 ? 0 : 1
  source = "../../../modules/auth0"

  admin_base_url    = "https://admin.${var.root_domain}"
  env_name          = var.environment_name
  smtp_from_address = "no-reply@${var.root_domain}"

  allowed_email_domains = var.environmental_settings.allow_authentication_from_email_domains

  support_url = var.environmental_settings.forms_product_page_support_url
}

moved {
  from = module.auth0
  to   = module.auth0[0]
}
