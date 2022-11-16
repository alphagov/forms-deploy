data "aws_caller_identity" "current" {}

data "aws_elasticache_replication_group" "forms_runner" {
  replication_group_id = "forms-runner-${var.env_name}"
}


module "ecs_service" {
  source                 = "../ecs-service"
  env_name               = var.env_name
  application            = "forms-runner"
  sub_domain             = "submit"
  desired_task_count     = var.desired_task_count
  image                  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.eu-west-2.amazonaws.com/forms-runner-${var.env_name}:${var.image_tag}"
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
      name  = "RACK_ENV",
      value = "production"
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
    }
  ]

  secrets = [
    {
      name      = "API_KEY",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-runner-${var.env_name}/forms-api-key"
    },
    {
      name      = "NOTIFY_API_KEY",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-runner-${var.env_name}/notify-api-key"
    }
  ]
}

