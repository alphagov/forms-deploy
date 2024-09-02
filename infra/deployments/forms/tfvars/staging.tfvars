allowed_account_ids = ["972536609845"]
deploy_account_id   = "711966560482"
account_name        = "staging"
default_tags = {
  Environment = "staging"
}
environment_name = "staging"
environment_type = "staging"
environmental_settings = {
  auth0_domain                             = "govuk-forms-staging.uk.auth0.com"
  disable_auth0                            = false
  enable_auth0_splunk_log_stream           = false
  pause_databases_on_inactivity            = false
  pause_databases_after_inactivity_seconds = 300
  database_backup_retention_period_days    = 30
  allow_authentication_from_email_domains = [
    ".gov.uk",
  ]
  enable_alert_actions                = true
  forms_product_page_support_url      = "https://www.staging.forms.service.gov.uk/support"
  rds_maintenance_window              = "wed:04:00-wed:04:30"
  ips_to_block                        = []
  enable_shield_advanced_healthchecks = false
}
root_domain                = "staging.forms.service.gov.uk"
cloudfront_distribution_id = "E3PQV6DYYCB9KW"
additional_dns_records     = []
codestar_connection_arn    = "arn:aws:codestar-connections:eu-west-2:972536609845:connection/de05d028-2cbd-4d06-8946-0e4aca60f4ca"
container_registry         = "711966560482.dkr.ecr.eu-west-2.amazonaws.com"
forms_admin_settings = {
  cpu                        = 256
  memory                     = 512
  min_capacity               = 3
  max_capacity               = 3
  enable_maintenance_mode    = false
  auth_provider              = "auth0"
  previous_auth_provider     = "gds_sso"
  cloudwatch_metrics_enabled = true
  analytics_enabled          = true
  act_as_user_enabled        = true
  govuk_app_domain           = "staging.publishing.service.gov.uk"
  synchronize_to_mailchimp   = false
  repeatable_page_enabled    = false
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
  cpu                                                      = 256
  memory                                                   = 512
  min_capacity                                             = 3
  max_capacity                                             = 3
  enable_maintenance_mode                                  = false
  cloudwatch_metrics_enabled                               = true
  analytics_enabled                                        = true
  csv_submission_enabled                                   = false
  csv_submission_enabled_for_form_ids                      = []
  allow_human_readonly_roles_to_assume_csv_submission_role = false
}
scheduled_smoke_tests_settings = {
  enable_scheduled_smoke_tests = true
  form_url                     = "https://submit.staging.forms.service.gov.uk/form/12148/scheduled-smoke-test"
  frequency_minutes            = 10
  enable_alerting              = false
}
