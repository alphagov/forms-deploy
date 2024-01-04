module "users" {
  source = "../../../modules/users"
}

module "ses" {
  source = "../../../modules/ses"

  environment_type = var.environment_type

  hosted_zone_id = var.hosted_zone_id
  email_domain   = var.root_domain
  from_address   = "no-reply@${var.root_domain}"
  verified_email_addresses = concat(
    [
      for user in module.users.for_env[var.environment_type] : "${user}@digital.cabinet-office.gov.uk"
    ],
    [
      "forms--test-automation-groupt@digital.cabinet-office.gov.uk", # smoke tests user
    ],
  )
}
