module "auth0" {
  source = "../../../modules/auth0"

  admin_base_url    = "https://admin.forms.service.gov.uk"
  env_name          = "production"
  smtp_from_address = "no-reply@forms.service.gov.uk"

  allowed_email_domains = [
    ".gov.uk",
    ".mod.uk",
    "@cefas.co.uk",
    "@certoffice.org",
    "@ddc-mod.uk",
    "@hs2.org.uk",
    "@innovateuk.ukri.org",
    "@mod.uk",
    "@nationalhighways.co.uk",
    "@naturalengland.org.uk",
    "@slc.co.uk",
    "@ukces.org.uk",
    "@ukri.org",
    "@dounreay.com",
    "@marinemanagement.org.uk",
  ]
}
