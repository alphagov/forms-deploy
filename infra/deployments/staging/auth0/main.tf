module "auth0" {
  source = "../../../modules/auth0"

  admin_base_url        = "https://admin.staging.forms.service.gov.uk"
  env_name              = "staging"
  otp_expiry_length     = 900
  smtp_from_address     = "no-reply@staging.forms.service.gov.uk"
  allowed_email_domains = [".gov.uk", "pentestpartners.com"]
}
