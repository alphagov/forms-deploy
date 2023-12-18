module "alerts" {
  source      = "../../../modules/alerts"
  environment = var.environment_name

  minimum_healthy_host_count = 3
}
