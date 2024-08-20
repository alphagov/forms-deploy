allowed_account_ids = ["619109835131"]
deploy_account_id   = "711966560482"
default_tags = {
  Environment = "user-research"
}
environment_name = "user-research"
environment_type = "user_research"
environmental_settings = {
  auth0_domain                             = null
  disable_auth0                            = true
  enable_auth0_splunk_log_stream           = false
  pause_databases_on_inactivity            = true
  pause_databases_after_inactivity_seconds = 3600
  database_backup_retention_period_days    = 1
  allow_authentication_from_email_domains  = [] # user-research environment uses basic auth
  enable_alert_actions                     = false
  forms_product_page_support_url           = "https://www.research.forms.service.gov.uk/support"
  rds_maintenance_window                   = "wed:04:00-wed:04:30"
  ips_to_block                             = []
  enable_shield_advanced_healthchecks      = false
}
hosted_zone_id             = "Z011139325A6VARFKUQ54"
root_domain                = "research.forms.service.gov.uk"
cloudfront_distribution_id = "E5E6WGJ976UCF"
additional_dns_records     = []
codestar_connection_arn    = "arn:aws:codestar-connections:eu-west-2:619109835131:connection/6d5b8a26-b0d3-41da-ae2f-11a5f805bc3c"
container_repository       = "711966560482.dkr.ecr.eu-west-2.amazonaws.com"
forms_admin_settings = {
  cpu                        = 256
  memory                     = 512
  min_capacity               = 3
  max_capacity               = 3
  enable_maintenance_mode    = true
  auth_provider              = "basic_auth"
  previous_auth_provider     = null
  cloudwatch_metrics_enabled = false
  analytics_enabled          = false
  act_as_user_enabled        = false
  govuk_app_domain           = ""
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
  cpu                                 = 256
  memory                              = 512
  min_capacity                        = 3
  max_capacity                        = 3
  enable_maintenance_mode             = true
  cloudwatch_metrics_enabled          = false
  analytics_enabled                   = false
  csv_submission_enabled              = false
  csv_submission_enabled_for_form_ids = []
}
scheduled_smoke_tests_settings = {
  enable_scheduled_smoke_tests = false
  form_url                     = "not-applicable"
  frequency_minutes            = 10
  enable_alerting              = false
}
