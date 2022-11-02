data "aws_vpc" "forms" {
  filter {
    name   = "tag:Name"
    values = ["forms-${var.env_name}"]
  }
}

data "aws_vpc_endpoint" "s3" {
  vpc_id       = data.aws_vpc.forms.id
  service_name = "com.amazonaws.eu-west-2.s3"
}

data "aws_prefix_list" "private_s3" {
  prefix_list_id = data.aws_vpc_endpoint.s3.prefix_list_id
}

resource "aws_security_group" "baseline" {
  name        = "forms-baseline-${var.env_name}"
  description = "Ingress from VPC, egress to VPC and S3"
  vpc_id      = data.aws_vpc.forms.id

  ingress {
    description = "Container port from VPC"
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.forms.cidr_block]
  }

  egress {
    description = "Port 443 to VPC and S3"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = flatten([
      data.aws_vpc.forms.cidr_block,
      data.aws_prefix_list.private_s3.cidr_blocks
    ])
  }
}

resource "aws_ecs_task_definition" "task" {
  family = "${var.env_name}_${var.application}"
  container_definitions = jsonencode([
    {
      name        = var.application,
      environment = var.environment_variables,
      image       = var.image,
      essential   = true,
      portMappings = [
        {
          containerPort = var.container_port,
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "${var.application}-${var.env_name}",
          awslogs-region        = "eu-west-2",
          awslogs-stream-prefix = "${var.application}-${var.env_name}"
        }
      },
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  execution_role_arn = aws_iam_role.task_exec_role.arn
  task_role_arn      = aws_iam_role.task_role.arn

  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory

  network_mode = "awsvpc"
}

resource "aws_cloudwatch_log_group" "log" {
  name = "${var.application}-${var.env_name}"
}

data "aws_ecs_cluster" "forms" {
  cluster_name = "forms-${var.env_name}"
}

data "aws_subnets" "private" {
  filter {
    name = "tag:Name"
    values = [
      "private-a-${var.env_name}",
      "private-b-${var.env_name}",
      "private-c-${var.env_name}"
    ]
  }
}

resource "aws_lb_target_group" "tg" {
  name        = "forms-runner-${var.env_name}"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.forms.id
  target_type = "ip"

  health_check {
    path     = "/ping"
    matcher  = "200"
    protocol = "HTTP"
  }
}

data "aws_lb" "alb" {
  name = "forms-${var.env_name}"
}

data "aws_lb_listener" "main" {
  load_balancer_arn = data.aws_lb.alb.arn
  port              = 443
}

resource "aws_lb_listener_rule" "to_app" {
  listener_arn = data.aws_lb_listener.main.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  condition {
    host_header {
      values = ["${var.sub_domain}.*"]
    }
  }
}

resource "aws_ecs_service" "app_service" {
  name                               = var.application
  cluster                            = data.aws_ecs_cluster.forms.id
  task_definition                    = "${aws_ecs_task_definition.task.family}:${aws_ecs_task_definition.task.revision}"
  desired_count                      = var.desired_task_count
  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "50"
  #health_check_grace_period_seconds  = "30"

  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = var.application
    container_port   = 3000
  }

  lifecycle {
    prevent_destroy = false # Set to true before going-live
  }

  network_configuration {
    subnets          = data.aws_subnets.private.ids
    security_groups  = [aws_security_group.baseline.id]
    assign_public_ip = false
  }
}

