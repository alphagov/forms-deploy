module "alerts" {
  source = "./alerts"

  environment                = var.env_name
  minimum_healthy_host_count = 3
  enable_alert_actions       = var.enable_alert_actions
}