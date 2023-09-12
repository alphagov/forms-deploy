module "alerts" {
  source      = "../../../modules/alerts"
  environment = "production"

  minimum_healthy_host_count = 3
}
