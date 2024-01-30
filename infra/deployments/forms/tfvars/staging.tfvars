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
  allow_authentication_from_email_domains  = [".gov.uk"]
  enable_alert_actions                     = true
  forms_product_page_support_url           = "https://www.staging.forms.service.gov.uk/support"
  rds_maintenance_window                   = "mon:02:15-mon:02:45"
}
hosted_zone_id             = "Z05508474P9CXBK9UAH3"
root_domain                = "staging.forms.service.gov.uk"
cloudfront_distribution_id = "E3PQV6DYYCB9KW"
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
}