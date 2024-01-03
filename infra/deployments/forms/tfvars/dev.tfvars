allowed_account_ids = ["498160065950"]
default_tags = {
  Environment = "dev"
}
environment_name = "dev"
environment_type = "development"
environmental_settings = {
  pause_databases_on_inactivity            = false
  pause_databases_after_inactivity_seconds = 300
  database_backup_retention_period_days    = 30
  allow_authentication_from_email_domains  = [".gov.uk"]
  enable_alert_actions                     = false
}
hosted_zone_id             = "Z03210831GH1QDMJ7N5C8"
root_domain                = "dev.forms.service.gov.uk"
cloudfront_distribution_id = "E2BI70XAWS5P2T"
forms_admin_settings = {
  cpu                        = 256
  memory                     = 512
  min_capacity               = 3
  max_capacity               = 3
  enable_maintenance_mode    = false
  metrics_feature_flag       = true
  auth_provider              = "auth0"
  previous_auth_provider     = "gds_sso"
  cloudwatch_metrics_enabled = false
  govuk_app_domain           = "integration.publishing.service.gov.uk"
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
}