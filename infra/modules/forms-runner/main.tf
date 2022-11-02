data "aws_caller_identity" "current" {}


module "ecs_service" {
  source             = "../ecs_service"
  env_name           = var.env_name
  application        = "forms-runner"
  sub_domain         = "submit"
  desired_task_count = var.desired_task_count
  image              = "${data.aws_caller_identity.current.account_id}.dkr.ecr.eu-west-2.amazonaws.com/forms-runner-${var.env_name}:${var.image_tag}"
  cpu                = var.cpu
  memory             = var.memory
  container_port     = 3000

  # TODO: dummy values to get the app running. Update with real values.
  environment_variables = [
    {
      name  = "REDIS_URL",
      value = "rediss://dummy:6379"
    },
    {
      name  = "API_BASE",
      value = "https://forms-api-dev.london.cloudapps.digital"
    },
    {
      name  = "API_KEY",
      value = "something"
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
    }
  ]
}

