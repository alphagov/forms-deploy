module "auth0" {
  source = "../../../modules/auth0"

  admin_base_url        = "https://admin.forms.service.gov.uk"
  env_name              = "production"
  smtp_from_address     = "no-reply@forms.service.gov.uk"
  allowed_email_domains = [".gov.uk"]
}
