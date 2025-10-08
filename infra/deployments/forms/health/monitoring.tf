module "monitoring" {
  source = "./monitoring"

  environment_name                  = var.environment_name
  environment_type                  = var.environment_type
  container_registry                = var.container_registry
  scheduled_smoke_tests_settings    = var.scheduled_smoke_tests_settings
  deploy_account_id                 = var.deploy_account_id
  smoke_test_alarm_sns_topic_arn    = data.terraform_remote_state.forms_environment.outputs.pagerduty_eu_west_2_topic_arn
  eventbridge_dead_letter_queue_url = data.terraform_remote_state.forms_environment.outputs.eventbridge_dead_letter_queue_url
}
