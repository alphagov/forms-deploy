allowed_account_ids = ["619109835131"]
default_tags = {
  Environment = "user-research"
}
environment_name = "user-research"
environment_type = "user_research"
environmental_settings = {
  auth0_domain                             = null
  disable_auth0                            = true
  pause_databases_on_inactivity            = true
  pause_databases_after_inactivity_seconds = 3600
  database_backup_retention_period_days    = 1
  allow_authentication_from_email_domains  = [] # user-reserch environment uses basic auth
  enable_alert_actions                     = false
  forms_product_page_support_url           = "https://www.research.forms.service.gov.uk/support"
  rds_maintenance_window                   = "wed:04:00-wed:04:30"
  redis_backup_retention_period_days       = 2
}
hosted_zone_id             = "Z011139325A6VARFKUQ54"
root_domain                = "research.forms.service.gov.uk"
cloudfront_distribution_id = "E5E6WGJ976UCF"
codestar_connection_arn    = "arn:aws:codestar-connections:eu-west-2:619109835131:connection/6d5b8a26-b0d3-41da-ae2f-11a5f805bc3c"
container_repository       = "711966560482.dkr.ecr.eu-west-2.amazonaws.com"
forms_admin_settings = {
  cpu                                   = 256
  memory                                = 512
  min_capacity                          = 3
  max_capacity                          = 3
  enable_maintenance_mode               = false
  metrics_feature_flag                  = true
  submission_email_changed_feature_flag = true
  auth_provider                         = "basic_auth"
  previous_auth_provider                = null
  cloudwatch_metrics_enabled            = false
  govuk_app_domain                      = ""
  payment_links                         = false
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
  reference_numbers_enabled  = false
}
