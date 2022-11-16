data "aws_caller_identity" "current" {}

module "ecs_service" {
  source                 = "../ecs-service"
  env_name               = var.env_name
  application            = "forms-api"
  sub_domain             = "api"
  desired_task_count     = var.desired_task_count
  image                  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.eu-west-2.amazonaws.com/forms-api-${var.env_name}:${var.image_tag}"
  cpu                    = var.cpu
  memory                 = var.memory
  container_port         = 9292
  permit_internet_egress = true # TODO: necessary until VPC endpoint for SSM.
  permit_postgres_egress = true

  environment_variables = [
    {
      name  = "RACK_ENV",
      value = "production"
    }
  ]

  secrets = [
    {
      name      = "API_KEY",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-api-${var.env_name}/forms-api-key"
    },
    {
      name      = "DATABASE_URL",
      valueFrom = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/forms-api-${var.env_name}/database/url"
    }
  ]
}

