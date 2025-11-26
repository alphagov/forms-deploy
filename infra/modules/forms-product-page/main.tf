data "aws_caller_identity" "current" {}

locals {
  image = var.image_tag == null ? null : "${var.container_repository}:${var.image_tag}"
}

module "ecs_service" {
  source                       = "../ecs-service"
  env_name                     = var.env_name
  application                  = "forms-product-page"
  root_domain                  = var.root_domain
  sub_domain                   = "www.${var.root_domain}"
  listener_priority            = 400
  include_domain_root_listener = true
  image                        = local.image
  cpu                          = var.cpu
  memory                       = var.memory
  readonly_root_filesystem     = true
  container_port               = 3000
  permit_internet_egress       = true # Required for Sentry.io and AWS SSM
  permit_postgres_egress       = true
  vpc_id                       = var.vpc_id
  vpc_cidr_block               = var.vpc_cidr_block
  private_subnet_ids           = var.private_subnet_ids
  alb_arn_suffix               = var.alb_arn_suffix
  alb_listener_arn             = var.alb_listener_arn
  ecs_cluster_arn              = var.ecs_cluster_arn
  cloudfront_secret            = var.cloudfront_secret

  kinesis_subscription_role_arn = var.kinesis_subscription_role_arn

  scaling_rules = {
    min_capacity                                = var.min_capacity
    max_capacity                                = var.max_capacity
    p95_response_time_scaling_threshold_seconds = 1
    scale_in_cooldown                           = 180
    scale_out_cooldown                          = 60
  }

  environment_variables = [
    {
      name  = "RACK_ENV",
      value = "production"
    },
    {
      name  = "RAILS_ENV",
      value = "production"
    },
    {
      name  = "SETTINGS__SENTRY__ENVIRONMENT",
      value = "aws-${var.env_name}"
    },
    {
      name  = "SETTINGS__FORMS_ENV",
      value = var.env_name
    },
    {
      name  = "SETTINGS__ZENDESK__SUBDOMAIN",
      value = var.zendesk_subdomain
    },
    {
      name  = "SETTINGS__FORMS_ADMIN__BASE_URL",
      value = var.admin_base_url
    },
  ]

  secrets = [
    {
      name      = "SETTINGS__SENTRY__DSN",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-product-page-${var.env_name}/sentry/dsn"
    },
    {
      name      = "SETTINGS__ZENDESK__API_USER",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-product-page-${var.env_name}/zendesk/api-user"
    },
    {
      name      = "SETTINGS__ZENDESK__API_TOKEN",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-product-page-${var.env_name}/zendesk/api-token"
    },
    {
      name      = "SECRET_KEY_BASE",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-product-page-${var.env_name}/secret-key-base"
    },
  ]
}
