module "monitoring" {
  source = "./monitoring"

  environment_name               = var.environment_name
  environment_type               = var.environment_type
  scheduled_smoke_tests_settings = var.scheduled_smoke_tests_settings
  smoke_test_alarm_sns_topic_arn = module.alerts.sns_topic_alert_pagerduty.arn
  deploy_account_id              = var.deploy_account_id
}