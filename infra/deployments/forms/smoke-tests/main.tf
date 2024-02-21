module "alerts" {
  count       = var.scheduled_smoke_tests_settings.enable_scheduled_smoke_tests ? 1 : 0
  source      = "../../../modules/smoke-tests"
  environment = var.environment_name

  smoke_test_form_url           = var.scheduled_smoke_tests_settings.smoke_test_form_url
  smoke_tests_frequency_minutes = var.scheduled_smoke_tests_settings.smoke_tests_frequency_minutes
}

