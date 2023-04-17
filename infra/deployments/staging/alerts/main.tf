module "alerts" {
  source      = "../../../modules/alerts"
  environment = "staging"

  minimum_healthy_host_count = 2
}
