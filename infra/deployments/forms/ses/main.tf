module "users" {
  source = "../../../modules/users"
}

module "ses" {
  source = "../../../modules/ses"

  environment = "production"

  email_domain = "forms.service.gov.uk"
  from_address = "no-reply@forms.service.gov.uk"
  verified_email_addresses = concat(
    [
      for user in module.users.for_env["production"] : "${user}@digital.cabinet-office.gov.uk"
    ],
    [
      "forms--test-automation-groupt@digital.cabinet-office.gov.uk", # smoke tests user
    ],
  )
}
