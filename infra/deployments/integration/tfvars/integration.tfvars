account_name            = "integration"
aws_account_id          = "842676007477"
require_vpn_to_access   = true
codestar_connection_arn = "arn:aws:codeconnections:eu-west-2:842676007477:connection/ccaca0a3-ee66-45dc-89ab-aa3f3339020a"
deploy_account_id       = "711966560482"
send_logs_to_cyber      = false

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
