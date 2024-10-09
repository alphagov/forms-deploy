variable "image_tag" {
  type        = string
  description = "The image tag to deploy"
  nullable    = true
  default     = null
}

module "forms_api" {
  source               = "../../../modules/forms-api"
  env_name             = var.environment_name
  root_domain          = var.root_domain
  container_repository = "${var.container_registry}/forms-api-deploy"
  image_tag            = var.image_tag
  cpu                  = var.forms_api_settings.cpu
  memory               = var.forms_api_settings.memory
  min_capacity         = var.forms_api_settings.min_capacity
  max_capacity         = var.forms_api_settings.max_capacity
  deploy_account_id    = var.deploy_account_id
  vpc_id               = data.terraform_remote_state.forms_environment.outputs.vpc_id
  vpc_cidr_block       = data.terraform_remote_state.forms_environment.outputs.vpc_cidr_block
  private_subnet_ids   = [for id in data.terraform_remote_state.forms_environment.outputs.private_subnet_ids : id]
}

