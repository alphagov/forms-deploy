module "alerts" {
  source = "./alerts"

  environment                = var.environment_name
  minimum_healthy_host_count = 3
  enable_alert_actions       = var.environmental_settings.enable_alert_actions
}