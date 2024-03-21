allowed_account_ids = ["972536609845"]
default_tags = {
  Environment = "staging"
}
environment_name = "staging"
environment_type = "staging"
environmental_settings = {
  auth0_domain                             = "govuk-forms-staging.uk.auth0.com"
  disable_auth0                            = false
  pause_databases_on_inactivity            = false
  pause_databases_after_inactivity_seconds = 300
  database_backup_retention_period_days    = 30
  allow_authentication_from_email_domains = [
    ".gov.uk",
    "@digitalaccessibilitycentre.org"
  ]
  enable_alert_actions               = true
  forms_product_page_support_url     = "https://www.staging.forms.service.gov.uk/support"
  rds_maintenance_window             = "wed:04:00-wed:04:30"
  redis_backup_retention_period_days = 2
  ips_to_block                       = []
}
hosted_zone_id             = "Z05508474P9CXBK9UAH3"
root_domain                = "staging.forms.service.gov.uk"
cloudfront_distribution_id = "E3PQV6DYYCB9KW"
codestar_connection_arn    = "arn:aws:codestar-connections:eu-west-2:972536609845:connection/de05d028-2cbd-4d06-8946-0e4aca60f4ca"
container_repository       = "711966560482.dkr.ecr.eu-west-2.amazonaws.com"
forms_admin_settings = {
  cpu                                   = 256
  memory                                = 512
  min_capacity                          = 3
  max_capacity                          = 3
  enable_maintenance_mode               = false
  metrics_feature_flag                  = true
  submission_email_changed_feature_flag = true
  auth_provider                         = "auth0"
  previous_auth_provider                = "gds_sso"
  cloudwatch_metrics_enabled            = true
  govuk_app_domain                      = "staging.publishing.service.gov.uk"
  payment_links                         = true
  reference_numbers_enabled             = true
}
forms_api_settings = {
  cpu          = 256
  memory       = 512
  min_capacity = 3
  max_capacity = 3
}
forms_product_page_settings = {
  cpu          = 256
  memory       = 512
  min_capacity = 3
  max_capacity = 3
}
forms_runner_settings = {
  cpu                        = 256
  memory                     = 512
  min_capacity               = 3
  max_capacity               = 3
  enable_maintenance_mode    = false
  cloudwatch_metrics_enabled = true
  reference_numbers_enabled  = true
}
