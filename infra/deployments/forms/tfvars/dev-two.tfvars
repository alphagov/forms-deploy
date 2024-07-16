allowed_account_ids = ["590183811416"]
default_tags = {
  Environment = "dev-two"
}
environment_name = "dev-two"
environment_type = "development"
environmental_settings = {
  auth0_domain                             = "govuk-forms-dev.uk.auth0.com"
  disable_auth0                            = true
  enable_auth0_splunk_log_stream           = false
  pause_databases_on_inactivity            = false
  pause_databases_after_inactivity_seconds = 300
  database_backup_retention_period_days    = 30
  allow_authentication_from_email_domains  = [".gov.uk"]
  enable_alert_actions                     = false
  forms_product_page_support_url           = "https://www.dev-two.forms.service.gov.uk/support"
  rds_maintenance_window                   = "wed:04:00-wed:04:30"
  ips_to_block                             = []
  enable_shield_advanced_healthchecks      = false
}
hosted_zone_id             = "Z0681026312FHG53240YA"
root_domain                = "dev-two.forms.service.gov.uk"
cloudfront_distribution_id = "E2WYSRMIAI5DSB"
codestar_connection_arn    = "arn:aws:codestar-connections:eu-west-2:590183811416:connection/2df0ab61-2576-48a5-ba47-63f941c398a0"
container_repository       = "711966560482.dkr.ecr.eu-west-2.amazonaws.com"
forms_admin_settings = {
  cpu                        = 256
  memory                     = 512
  min_capacity               = 3
  max_capacity               = 3
  enable_maintenance_mode    = false
  groups_feature_flag        = true
  auth_provider              = "auth0"
  previous_auth_provider     = "gds_sso"
  cloudwatch_metrics_enabled = false
  analytics_enabled          = false
  act_as_user_enabled        = true
  govuk_app_domain           = "integration.publishing.service.gov.uk"
  synchronize_to_mailchimp   = false
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
  cloudwatch_metrics_enabled = false
  analytics_enabled          = false
}
scheduled_smoke_tests_settings = {
  enable_scheduled_smoke_tests = false
  form_url                     = "https://submit.dev-two.forms.service.gov.uk/form/11120/scheduled-smoke-test"
  frequency_minutes            = 10
  enable_alerting              = false
}
