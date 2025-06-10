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
  rate_limit_bypass_cidrs             = []
  enable_shield_advanced_healthchecks = false
  allow_pagerduty_alerts              = false
}
root_domain             = "staging.forms.service.gov.uk"
additional_dns_records  = []
codestar_connection_arn = "arn:aws:codestar-connections:eu-west-2:972536609845:connection/de05d028-2cbd-4d06-8946-0e4aca60f4ca"
container_registry      = "711966560482.dkr.ecr.eu-west-2.amazonaws.com"
dlq_arn                 = "arn:aws:sqs:eu-west-2:711966560482:eventbridge-dead-letter-queue"
send_logs_to_cyber      = true
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
  repeatable_page_enabled    = true
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
  cpu                                                             = 512
  memory                                                          = 1024
  min_capacity                                                    = 3
  max_capacity                                                    = 3
  enable_maintenance_mode                                         = false
  cloudwatch_metrics_enabled                                      = true
  analytics_enabled                                               = true
  api_v2_enabled                                                  = true
  allow_human_readonly_roles_to_assume_submissions_to_s3_role     = false
  allow_human_readonly_roles_to_assume_submissions_to_runner_role = false
  ses_submission_email_from_email_address                         = "no-reply@staging.forms.service.gov.uk"
  ses_submission_email_reply_to_email_address                     = "no-reply@staging.forms.service.gov.uk"
  queue_worker_capacity                                           = 1
}
scheduled_smoke_tests_settings = {
  enable_scheduled_smoke_tests = true
  form_url                     = "https://submit.staging.forms.service.gov.uk/form/12148/scheduled-smoke-test"
  frequency_minutes            = 10
  enable_alerting              = false
}
end_to_end_test_settings = {
  aws_s3_role_arn = "arn:aws:iam::972536609845:role/govuk-s3-end-to-end-test-staging"
  aws_s3_bucket   = "govuk-forms-submissions-to-s3-test"
  s3_form_id      = "13657"
}
internal_secrets = [
  "databases_forms_admin_app_password",
  "databases_forms_admin_app_url",
  "databases_forms_admin_root_password",
  "databases_forms_api_app_password",
  "databases_forms_api_app_url",
  "databases_forms_runner_app_password",
  "databases_forms_runner_app_url",
  "databases_forms_runner_queue_password",
  "databases_forms_runner_queue_url",
  "databases_forms_runner_root_password",
  "forms_admin_forms_api_key",
  "forms_admin_secret_key_base",
  "forms_api_forms_api_key",
  "forms_api_secret_key_base",
  "forms_product_page_secret_key_base",
  "forms_runner_e2e_tests_submissions_status_api_shared_secret",
  "forms_runner_forms_api_key",
  "forms_runner_secret_key_base",
  "forms_runner_submission_status_api_shared_secret",
  "ses_auth0_smtp_password",
  "ses_auth0_smtp_username",
]