module "deployer_access" {
  source         = "../../modules/deployer-access"
  env_name       = var.environment_name
  hosted_zone_id = var.hosted_zone_id
}

