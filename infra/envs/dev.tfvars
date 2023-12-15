allowed_account_ids = ["498160065950"]
default_tags = {
  Environment = "development"
}
environment_name = "development"
environment_type = "dev"
environmental_settings = {
  pause_databases_on_inactivity            = false
  pause_databases_after_inactivity_seconds = 300
  allow_authentication_from_email_domains  = [".gov.uk"]
}
root_domain = "dev.forms.service.gov.uk"
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