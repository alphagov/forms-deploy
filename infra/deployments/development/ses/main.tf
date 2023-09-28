module "ses" {
  source = "../../../modules/ses"

  verified_email_addresses = [
    "alice.carr@digital.cabinet-office.gov.uk",
    "laurence.debruxelles@digital.cabinet-office.gov.uk",
    "catalina.garcia@digital.cabinet-office.gov.uk",
    "forms--test-automation-groupt@digital.cabinet-office.gov.uk", # smoke tests user
  ]

  user = "auth0"
}
