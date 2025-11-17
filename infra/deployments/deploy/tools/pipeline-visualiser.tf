locals {
  pipeline_visualiser_image = coalesce(
    var.pipeline_visualiser_container_image_uri,
    data.aws_ecs_container_definition.pipeline_visualiser_active_container.image
  )
}
##
# AWS ECS on Fargate
##
data "aws_ecs_task_definition" "pipeline_visualiser_active_task" {
  task_definition = "pipeline-visualiser"
}

data "aws_ecs_container_definition" "pipeline_visualiser_active_container" {
  task_definition = data.aws_ecs_task_definition.pipeline_visualiser_active_task.id
  container_name  = "pipeline-visualiser"
}

resource "aws_ecs_task_definition" "pipeline_visualiser_task" {
  family = "pipeline-visualiser"
  container_definitions = jsonencode([{
    name = "pipeline-visualiser",
    environment = [
      {
        "name" : "RACK_ENV",
        "value" : "PRODUCTION"
      }
    ],
    image     = local.pipeline_visualiser_image
    essential = true,
    portMappings = [
      {
        containerPort = 4567,
      }
    ],
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = aws_cloudwatch_log_group.pipeline_visualiser.name
        awslogs-region        = "eu-west-2",
        awslogs-stream-prefix = "pipeline-visualiser"
      }
    },
    readonlyRootFilesystem = true
  }])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  execution_role_arn = aws_iam_role.ecs_task_exec_role.arn
  task_role_arn      = aws_iam_role.pipeline_visualiser_task.arn

  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  // As we deploy the pipeline visualiser versions with codepipeline, terraform is not the source of truth for the task definition image. Therefore use `track_latest` to avoid drift.
  track_latest = true

  network_mode = "awsvpc"
}

resource "aws_ecs_service" "pipeline_visualiser_service" {
  #checkov:skip=CKV_AWS_332:We don't want to target "LATEST" and get a surprise when a new version is released.
  #checkov:skip=CKV2_FORMS_AWS_2:We don't autoscale this service
  name                               = "pipeline-visualiser"
  cluster                            = aws_ecs_cluster.tools.arn
  task_definition                    = aws_ecs_task_definition.pipeline_visualiser_task.arn
  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"
  desired_count                      = 1

  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  load_balancer {
    target_group_arn = aws_lb_target_group.pipeline_visualiser_tg.arn
    container_name   = "pipeline-visualiser"
    container_port   = "4567"
  }

  lifecycle {
    prevent_destroy = true # ECS services cannot be destructively replaced without downtime. This helps to avoid accidentally doing so.
  }

  network_configuration {
    subnets = [for s in aws_subnet.pipeline_visualiser_subnets : s.id]
    security_groups = [
      aws_security_group.pipeline_visualiser.id,
      aws_security_group.vpc_endpoints.id
    ]
    assign_public_ip = false
  }
}

##
# Security groups
##
resource "aws_security_group" "pipeline_visualiser" {
  #checkov:skip=CKV2_AWS_5:The security groups are attached in ecs.tf
  name        = "pipeline-visualiser"
  description = "Ingress from VPC, egress to VPC and S3"
  vpc_id      = aws_vpc.tools.id
}

resource "aws_security_group_rule" "ingress_from_vpc" {
  description       = "permit inbound form the VPC to the container port"
  type              = "ingress"
  from_port         = 4567
  to_port           = 4567
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.tools.cidr_block]
  security_group_id = aws_security_group.pipeline_visualiser.id
}

resource "aws_security_group_rule" "egress_to_vpc" {
  description       = "Permit outbound to VPC CIDR on 443"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.tools.cidr_block]
  security_group_id = aws_security_group.pipeline_visualiser.id
}

##
# AWS CloudWatch
##
resource "aws_cloudwatch_log_group" "pipeline_visualiser" {
  #checkov:skip=CKV_AWS_338:We're happy with 30 days retention for now
  #checkov:skip=CKV_AWS_158:Default AWS SSE is sufficient, no need for CM KMS.
  name              = "pipeline-visualiser"
  retention_in_days = 30
}

##
# Load balancing
##
resource "aws_lb_target_group" "pipeline_visualiser_tg" {
  #checkov:skip=CKV_AWS_378: We're happy that this is internal traffic within our vpc and we do not want the complexity cost of setting up TLS between the load balancer and application
  name        = "pipeline-visualiser"
  port        = 4567
  protocol    = "HTTP"
  vpc_id      = aws_vpc.tools.id
  target_type = "ip"

  deregistration_delay = "60"

  health_check {
    path     = "/"
    matcher  = "200"
    protocol = "HTTP"

    interval            = 11
    timeout             = 10
    unhealthy_threshold = 3
    healthy_threshold   = 2
  }
}

resource "aws_lb_listener_rule" "to_app" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pipeline_visualiser_tg.arn
  }

  condition {
    host_header {
      values = ["pipelines.tools.forms.service.gov.uk"]
    }
  }
}

##
# DNS
##
resource "aws_route53_record" "pipelines_tools_forms_service_gov_uk" {
  name    = "pipelines.tools.forms.service.gov.uk"
  type    = "A"
  zone_id = data.aws_route53_zone.tools_domain_zone.id

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

##
# IAM
##
module "forms_people" {
  source = "../../../modules/users"
}

data "aws_iam_role" "readonly_people_roles" {
  # Readonly roles are made for each of the people in these lists
  for_each = toset(concat(
    module.forms_people.with_role["deploy_admin"],
    module.forms_people.with_role["deploy_support"],
    module.forms_people.with_role["deploy_readonly"]
  ))
  name = "${each.value}-readonly"
}

resource "aws_iam_role" "pipeline_visualiser_task" {
  name = "deploy-pipeline-visualiser-ecs-task"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
      # We want readonly roles created for humans to be able to
      # assume this role so we can make use of it in development
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = [for r in data.aws_iam_role.readonly_people_roles : r.arn]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "allow_pipeline_visualiser_to_assume_roles" {
  role = aws_iam_role.pipeline_visualiser_task.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowAssumeRole"
        Action   = "sts:AssumeRole"
        Effect   = "Allow"
        Resource = ["arn:aws:iam::*:role/codepipeline-readonly"]
      }
    ]
  })
}
