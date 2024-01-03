allowed_account_ids = ["619109835131"]
default_tags = {
  Environment = "user-research"
}
environment_name = "research"
environment_type = "user_research"
environmental_settings = {
  pause_databases_on_inactivity            = true
  pause_databases_after_inactivity_seconds = 3600
  database_backup_retention_period_days    = 1
  allow_authentication_from_email_domains  = [] # user-reserch environment uses basic auth
  enable_alert_actions                     = false
}
hosted_zone_id             = "Z011139325A6VARFKUQ54"
root_domain                = "research.forms.service.gov.uk"
cloudfront_distribution_id = "E5E6WGJ976UCF"
forms_admin_settings = {
  cpu                            = 256
  memory                         = 512
  min_capacity                   = 3
  max_capacity                   = 3
  enable_maintenance_mode        = false
  metrics_feature_flag           = true
  auth_provider                  = "basic_auth"
  previous_auth_provider         = null
  cloudwatch_metrics_enabled     = false
  govuk_app_domain               = ""
  forms_product_page_support_url = "https://www.research.forms.service.gov.uk/support"
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