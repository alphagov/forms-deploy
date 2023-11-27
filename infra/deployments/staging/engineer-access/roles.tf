module "users" {
  source = "../../../modules/users"
}

module "engineer_access" {
  source   = "../../../modules/engineer-access"
  env_name = "staging"
  admins   = module.users.with_role["staging_admin"]
  support  = module.users.with_role["staging_support"]
  readonly = module.users.with_role["staging_readonly"]

  # Pentesters may not have GDS domains so our pattern using the 'users' module
  # doesn't necessarily work.
  pentesters = [
    "nick.simpson@pentestpartners.com",
    "alice.carr@digital.cabinet-office.gov.uk",      # To help debugging if necessary.
    "andy.hunt@digital.cabinet-office.gov.uk",       # To help debugging if necessary.
    "catalina.garcia@digital.cabinet-office.gov.uk", # To help debugging if necessary.
    "dan.worth@digital.cabinet-office.gov.uk"        # To help debugging if necessary.
  ]

  pentester_cidrs = [
    "212.38.169.64/27",  #Temp: Pentest Partners For Testing
    "78.129.217.224/27", #Temp: Pentest Partners For Testing
    "91.238.238.0/25",   #Temp: Pentest Partners For Testing
  ]
}
