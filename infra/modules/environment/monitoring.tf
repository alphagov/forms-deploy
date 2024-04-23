module "monitoring" {
  source = "./monitoring"

  environment_name               = var.env_name
  environment_type               = var.env_type
  scheduled_smoke_tests_settings = var.scheduled_smoke_tests_settings
}