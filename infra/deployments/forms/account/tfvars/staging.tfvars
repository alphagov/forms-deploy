account_name            = "staging"
aws_account_id          = "972536609845"
environment_name        = "staging"
environment_type        = "staging"
require_vpn_to_access   = true
apex_domain             = "staging.forms.service.gov.uk"
dns_delegation_records  = {}
codestar_connection_arn = "arn:aws:codestar-connections:eu-west-2:972536609845:connection/de05d028-2cbd-4d06-8946-0e4aca60f4ca"
deploy_account_id       = "711966560482"
pentester_email_addresses = [
  "andy.hunt@digital.cabinet-office.gov.uk",    # To help debugging if necessary.
  "sarah.young1@digital.cabinet-office.gov.uk", # To help debugging if necessary.
  "nick.simpson@pentestpartners.com",
  "daniela.schoeffmann@pentestpartners.com",
  "james.palmer@pentestpartners.com",
]
pentester_cidr_ranges = [
  "212.38.169.64/27",
  "78.129.217.224/27",
  "91.238.238.0/25",
  "91.238.238.128/27",
  "91.238.238.160/27",
  "91.238.238.192/27"
]
