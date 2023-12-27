allowed_account_ids = ["443944947292"]
default_tags = {
  Environment = "production"
}
environment_name = "production"
environment_type = "production"
environmental_settings = {
  auth0_domain                             = "govuk-forms.uk.auth0.com"
  disable_auth0                            = false
  pause_databases_on_inactivity            = false
  pause_databases_after_inactivity_seconds = 60 * 60 * 24 # Set to 24 hours for inactivity just in case the pause_database_on_inactivity flag is inverted or ignored
  database_backup_retention_period_days    = 30
  enable_alert_actions                     = true
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
    "@gov.scot",
  ]
  forms_product_page_support_url = "https://www.forms.service.gov.uk/support"
  rds_maintenance_window         = "wed:04:00-wed:04:30"
  ips_to_block                   = []
}
hosted_zone_id             = "Z029841414A29LF7J7EDY"
root_domain                = "forms.service.gov.uk"
cloudfront_distribution_id = "EXITHSOVYUXHW"
codestar_connection_arn    = "arn:aws:codestar-connections:eu-west-2:443944947292:connection/c253c931-651d-4d48-950a-c1ac2dfd7ca8"
container_repository       = "711966560482.dkr.ecr.eu-west-2.amazonaws.com"
forms_admin_settings = {
  cpu                                   = 256
  memory                                = 512
  min_capacity                          = 6
  max_capacity                          = 12
  enable_maintenance_mode               = false
  metrics_feature_flag                  = true
  submission_email_changed_feature_flag = true
  auth_provider                         = "auth0"
  previous_auth_provider                = "gds_sso"
  cloudwatch_metrics_enabled            = true
  govuk_app_domain                      = "publishing.service.gov.uk"
  payment_links                         = false
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
  reference_numbers_enabled  = false
}
