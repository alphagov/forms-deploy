data "aws_caller_identity" "current" {}

data "aws_elasticache_replication_group" "forms_runner" {
  replication_group_id = "forms-runner-${var.env_name}"
}

locals {
  deploy_account_id = "711966560482"
}

module "ecs_service" {
  source                 = "../ecs-service"
  env_name               = var.env_name
  application            = "forms-runner"
  sub_domain             = "submit"
  desired_task_count     = var.desired_task_count
  image                  = "${local.deploy_account_id}.dkr.ecr.eu-west-2.amazonaws.com/forms-runner-deploy:${var.image_tag}"
  cpu                    = var.cpu
  memory                 = var.memory
  container_port         = 3000
  permit_internet_egress = true
  permit_redis_egress    = true

  # TODO: dummy values to get the app running. Update with real values.
  environment_variables = [
    {
      name  = "REDIS_URL",
      value = "rediss://${data.aws_elasticache_replication_group.forms_runner.primary_endpoint_address}:${data.aws_elasticache_replication_group.forms_runner.port}"
    },
    {
      name  = "API_BASE",
      value = var.api_base_url
    },
    {
      #TODO Delete once config settings changes have been deployed
      name  = "SETTINGS__FORMS_API__BASE_URL",
      value = var.api_base_url
    },
    {
      name  = "RACK_ENV",
      value = "production"
    },
    {
      name  = "RAILS_LOG_TO_STDOUT",
      value = "true"
    },
    {
      name  = "RAILS_ENV",
      value = "production"
    },
    {
      name  = "SECRET_KEY_BASE",
      value = "something"
    },
    {
      name  = "RAILS_SERVE_STATIC_FILES",
      value = "1"
    },
    {
      name  = "SENTRY_ENVIRONMENT",
      value = "aws-${var.env_name}"
    }
  ]

  secrets = [
    {
      #TODO Delete once config settings changes have been deployed
      name      = "API_KEY",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-runner-${var.env_name}/forms-api-key"
    },
    {
      name      = "SETTINGS__FORMS_API__AUTH_KEY",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-runner-${var.env_name}/forms-api-key"
    },
    {
      name      = "SETTINGS__GOVUK_NOTIFY__API_KEY",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-runner-${var.env_name}/notify-api-key"
    },
    {
      name      = "SENTRY_DSN",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-runner-${var.env_name}/sentry/dsn"
    }
  ]
}

