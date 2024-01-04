allowed_account_ids = ["443944947292"]
default_tags = {
  Environment = "production"
}
environment_name = "production"
environment_type = "production"
environmental_settings = {
  pause_databases_on_inactivity            = false
  pause_databases_after_inactivity_seconds = 60 * 60 * 24 # Set to 24 hours for inactivity just in case the pause_database_on_inactivity flag is inverted or ignored
  allow_authentication_from_email_domains = [
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
root_domain = "forms.service.gov.uk"
forms_admin_settings = {
  cpu                        = 256
  memory                     = 512
  min_capacity               = 6
  max_capacity               = 12
  enable_maintenance_mode    = false
  metrics_feature_flag       = true
  auth_provider              = "auth0"
  previous_auth_provider     = "gds_sso"
  cloudwatch_metrics_enabled = true
}
forms_api_settings = {
  cpu          = 512
  memory       = 1024
  min_capacity = 6
  max_capacity = 36
}
forms_product_page_settings = {
  cpu          = 256
  memory       = 512
  min_capacity = 3
  max_capacity = 9
}
forms_runner_settings = {
  cpu                        = 1024
  memory                     = 2048
  min_capacity               = 6
  max_capacity               = 36
  enable_maintenance_mode    = false
  cloudwatch_metrics_enabled = true
}