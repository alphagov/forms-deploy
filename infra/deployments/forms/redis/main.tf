locals {
  cache_engine = {
    name            = "valkey"
    version         = "8.2"
    parameter_group = "valkey8"
  }
}

module "redis" {
  source              = "../../../modules/redis"
  env_name            = var.environment_name
  vpc_id              = data.terraform_remote_state.forms_environment.outputs.vpc_id
  subnet_ids          = data.terraform_remote_state.forms_environment.outputs.private_subnet_ids
  ingress_cidr_blocks = [data.terraform_remote_state.forms_environment.outputs.vpc_cidr_block]
  multi_az_enabled    = var.environmental_settings.redis_multi_az_enabled
  engine              = local.cache_engine
}
