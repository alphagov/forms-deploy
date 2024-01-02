module "alerts" {
  source      = "../../../modules/alerts"
  environment = var.environment_name

  enable_alert_actions = var.environmental_settings.enable_alert_actions

  minimum_healthy_host_count = 3
}
