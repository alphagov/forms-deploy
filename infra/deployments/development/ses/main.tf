module "users" {
  source = "../../../modules/users"
}

module "ses" {
  source = "../../../modules/ses"

  verified_email_addresses = concat(
    [
      for user in module.users.for_env["dev"] : "${user}@digital.cabinet-office.gov.uk"
    ],
    [
      "forms--test-automation-groupt@digital.cabinet-office.gov.uk", # smoke tests user
    ],
  )

  smtp_user    = "auth0"
  from_address = "no-reply@dev.forms.service.gov.uk"
}
