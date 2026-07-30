# Grafana Tempo POC - dev environment only. See infra/modules/tempo/README.md
# for what this is and the one-time manual setup steps it needs.
module "tempo" {
  count  = var.tempo_settings.enabled ? 1 : 0
  source = "../../../modules/tempo"

  env_name    = var.environment_name
  root_domain = var.root_domain

  vpc_id                    = data.terraform_remote_state.forms_environment.outputs.vpc_id
  vpc_cidr_block            = data.terraform_remote_state.forms_environment.outputs.vpc_cidr_block
  private_subnet_ids        = data.terraform_remote_state.forms_environment.outputs.private_subnet_ids
  ecs_cluster_arn           = data.terraform_remote_state.forms_environment.outputs.ecs_cluster_arn
  alb_listener_arn          = data.terraform_remote_state.forms_environment.outputs.alb_main_listener_arn
  internal_alb_listener_arn = data.terraform_remote_state.forms_environment.outputs.internal_alb_listener_arn
  cloudfront_secret         = data.terraform_remote_state.forms_environment.outputs.cloudfront_secret

  listener_priority          = 900
  internal_listener_priority = 900

  cpu    = var.tempo_settings.cpu
  memory = var.tempo_settings.memory
}
