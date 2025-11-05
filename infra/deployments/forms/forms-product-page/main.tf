variable "forms_product_page_image_tag" {
  type        = string
  description = "The image tag to deploy"
  nullable    = true
  default     = null
}

module "forms_product_page" {
  source                        = "../../../modules/forms-product-page"
  env_name                      = var.environment_name
  root_domain                   = var.root_domain
  image_tag                     = var.forms_product_page_image_tag
  cpu                           = var.forms_product_page_settings.cpu
  memory                        = var.forms_product_page_settings.memory
  admin_base_url                = "https://admin.${var.root_domain}"
  min_capacity                  = var.forms_product_page_settings.min_capacity
  max_capacity                  = var.forms_product_page_settings.max_capacity
  deploy_account_id             = var.deploy_account_id
  container_repository          = "${var.container_registry}/forms-product-page-deploy"
  vpc_id                        = data.terraform_remote_state.forms_environment.outputs.vpc_id
  vpc_cidr_block                = data.terraform_remote_state.forms_environment.outputs.vpc_cidr_block
  private_subnet_ids            = data.terraform_remote_state.forms_environment.outputs.private_subnet_ids
  ecs_cluster_arn               = data.terraform_remote_state.forms_environment.outputs.ecs_cluster_arn
  alb_arn_suffix                = data.terraform_remote_state.forms_environment.outputs.alb_arn_suffix
  alb_listener_arn              = data.terraform_remote_state.forms_environment.outputs.alb_main_listener_arn
  cloudfront_secret             = data.terraform_remote_state.forms_environment.outputs.cloudfront_secret
  kinesis_subscription_role_arn = data.terraform_remote_state.account.outputs.kinesis_subscription_role_arn
}
