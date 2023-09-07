module "auth0" {
  source = "../../../modules/auth0"

  admin_base_url = "https://admin.dev.forms.service.gov.uk"
  env_name       = "dev"
}
