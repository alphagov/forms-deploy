############################################
# Doglike resources
############################################

# Log group
resource "aws_cloudwatch_log_group" "doglike" {
  name              = "/ecs/${var.name_prefix}-doglike"
  retention_in_days = var.log_retention_days
}

# Execution and Task roles
resource "aws_iam_role" "execution_doglike" {
  name               = "${var.name_prefix}-doglike-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}

resource "aws_iam_role" "task_doglike" {
  name               = "${var.name_prefix}-doglike-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}

resource "aws_iam_role_policy_attachment" "execution_logs_doglike" {
  role       = aws_iam_role.execution_doglike.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "execution_secret_doglike" {
  name   = "${var.name_prefix}-doglike-execution-secret-access"
  policy = data.aws_iam_policy_document.execution_secret_doglike.json
}

data "aws_iam_policy_document" "execution_secret_doglike" {
  statement {
    sid       = "SecretReadDoglike"
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = [var.secrets.doglike_arn]
  }
}

resource "aws_iam_role_policy_attachment" "execution_doglike_secret" {
  role       = aws_iam_role.execution_doglike.name
  policy_arn = aws_iam_policy.execution_secret_doglike.arn
}

resource "aws_iam_role_policy_attachment" "execution_extra_dog" {
  for_each   = toset(var.task_execution_role_additional_policies)
  role       = aws_iam_role.execution_doglike.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "task_extra_dog" {
  for_each   = toset(var.task_role_additional_policies)
  role       = aws_iam_role.task_doglike.name
  policy_arn = each.value
}

# Container definition and derived secrets
locals {
  doglike_container_definition = {
    name      = "doglike"
    image     = local.image_to_use
    essential = true
    command   = ["/bin/sh", "-c", "while true; do head=$(printf '%s' \"$DUMMY_SECRET\" | cut -c1-8); echo \"$(date) $ENVTYPE secret head: $head\"; sleep 20; done"]
    environment = [
      { name = "ENVTYPE", value = "doglike" }
    ]
    secrets = [
      { name = "DUMMY_SECRET", valueFrom = var.secrets.doglike_arn }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.doglike.name
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs"
      }
    }
  }

  doglike_secret_arns  = [for s in local.doglike_container_definition.secrets : s.valueFrom if startswith(s.valueFrom, "arn:aws:secretsmanager:")]
  doglike_secret_names = [for arn in local.doglike_secret_arns : regex("^arn:aws:secretsmanager:[^:]+:[0-9]+:secret:([^:]+)", arn)[0]]
  doglike_watched_ids  = distinct(concat(local.doglike_secret_arns, local.doglike_secret_names, var.extra_watched_doglike))
}

# Task definition
resource "aws_ecs_task_definition" "doglike" {
  family                   = "${var.name_prefix}-doglike"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)
  execution_role_arn       = aws_iam_role.execution_doglike.arn
  task_role_arn            = aws_iam_role.task_doglike.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions = jsonencode([local.doglike_container_definition])
}

# Service
resource "aws_ecs_service" "doglike" {
  name                   = "${var.name_prefix}-doglike"
  cluster                = aws_ecs_cluster.this.id
  task_definition        = aws_ecs_task_definition.doglike.arn
  desired_count          = var.desired_count
  launch_type            = "FARGATE"
  platform_version       = "LATEST"
  enable_execute_command = var.enable_execute_command

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = var.assign_public_ip
  }
}

# Service ARN local
locals {
  doglike_service_arn = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:service/${aws_ecs_cluster.this.id}/${aws_ecs_service.doglike.id}"
}

# Autoscaling
resource "aws_appautoscaling_target" "doglike" {
  count              = var.enable_service_auto_scaling ? 1 : 0
  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.doglike.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "doglike_cpu" {
  count              = var.enable_service_auto_scaling ? 1 : 0
  name               = "${var.name_prefix}-doglike-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.doglike[0].resource_id
  scalable_dimension = aws_appautoscaling_target.doglike[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.doglike[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.autoscaling_target_cpu
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

# Lambda role/policy/logs/function
resource "aws_iam_role" "doglike_lambda" {
  name               = "${var.name_prefix}-doglike-redeploy"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

data "aws_iam_policy_document" "doglike_lambda_inline" {
  statement {
    sid       = "EcsUpdate"
    actions   = ["ecs:UpdateService"]
    resources = [local.doglike_service_arn]
  }
  statement {
    sid       = "EcsDescribe"
    actions   = ["ecs:DescribeServices", "ecs:DescribeClusters"]
    resources = ["*"]
  }
  statement {
    sid       = "Logs"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "doglike_lambda" {
  name   = "${var.name_prefix}-doglike-redeploy-inline"
  role   = aws_iam_role.doglike_lambda.id
  policy = data.aws_iam_policy_document.doglike_lambda_inline.json
}

resource "aws_cloudwatch_log_group" "doglike_lambda" {
  name              = "/aws/lambda/${var.name_prefix}-doglike-redeploy"
  retention_in_days = var.log_retention_days
}

data "archive_file" "doglike_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/handler.py"
  output_path = "${path.module}/.build/${var.name_prefix}-doglike-redeploy.zip"
}

resource "aws_lambda_function" "doglike" {
  function_name    = "${var.name_prefix}-doglike-redeploy"
  role             = aws_iam_role.doglike_lambda.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.doglike_lambda_zip.output_path
  source_code_hash = data.archive_file.doglike_lambda_zip.output_base64sha256

  environment {
    variables = {
      TARGET_CLUSTER_ARN = aws_ecs_cluster.this.arn
      TARGET_SERVICE_ARN = local.doglike_service_arn
      WATCHED_SECRETS    = jsonencode(local.doglike_watched_ids)
    }
  }
}

# Events and permissions
resource "aws_cloudwatch_event_rule" "doglike" {
  name = "${var.name_prefix}-doglike-redeploy"
  event_pattern = jsonencode({
    source      = ["aws.secretsmanager"],
    detail-type = ["AWS API Call via CloudTrail"],
    detail = {
      eventSource       = ["secretsmanager.amazonaws.com"],
      eventName         = ["PutSecretValue", "UpdateSecretVersionStage", "RotateSecret"],
      requestParameters = { secretId = local.doglike_watched_ids }
    }
  })
}

resource "aws_cloudwatch_event_target" "doglike" {
  rule      = aws_cloudwatch_event_rule.doglike.name
  target_id = "doglike-lambda"
  arn       = aws_lambda_function.doglike.arn
}

resource "aws_lambda_permission" "allow_events_doglike" {
  statement_id  = "AllowExecutionFromEventBridgeDoglike"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.doglike.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.doglike.arn
}
