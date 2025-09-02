locals {
  default_image = "public.ecr.aws/docker/library/busybox:latest"
}

# ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = var.name_prefix
}

# Log groups per env-type
resource "aws_cloudwatch_log_group" "catlike" {
  name              = "/ecs/${var.name_prefix}-catlike"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "doglike" {
  name              = "/ecs/${var.name_prefix}-doglike"
  retention_in_days = var.log_retention_days
}

# IAM roles and policies - one set per env to keep least-privilege separated

# Execution roles
resource "aws_iam_role" "execution_catlike" {
  name               = "${var.name_prefix}-catlike-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}

resource "aws_iam_role" "execution_doglike" {
  name               = "${var.name_prefix}-doglike-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}

# Task roles
resource "aws_iam_role" "task_catlike" {
  name               = "${var.name_prefix}-catlike-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}

resource "aws_iam_role" "task_doglike" {
  name               = "${var.name_prefix}-doglike-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
}

# Trust policy for ECS tasks
data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Minimal execution policies (logs + optional ECR auth) and secret access to the specific ARN.
# Note: ECS container secrets resolution uses the TASK EXECUTION ROLE, so the Secrets Manager
# permissions are attached to the execution roles here (not the task roles).

# Execution policy common fragment: logs + ECR get auth token
# Use AWS managed policies instead of inline where practical
resource "aws_iam_role_policy_attachment" "execution_logs_catlike" {
  role       = aws_iam_role.execution_catlike.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "execution_logs_doglike" {
  role       = aws_iam_role.execution_doglike.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Allow optional extra policies on execution roles
resource "aws_iam_role_policy_attachment" "execution_extra" {
  for_each   = toset(var.task_execution_role_additional_policies)
  role       = aws_iam_role.execution_catlike.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "execution_extra_dog" {
  for_each   = toset(var.task_execution_role_additional_policies)
  role       = aws_iam_role.execution_doglike.name
  policy_arn = each.value
}

# Task role policies to allow secret access only to the provided ARN
resource "aws_iam_policy" "execution_secret_catlike" {
  name   = "${var.name_prefix}-catlike-execution-secret-access"
  policy = data.aws_iam_policy_document.execution_secret_catlike.json
}

data "aws_iam_policy_document" "execution_secret_catlike" {
  statement {
    sid     = "SecretReadCatlike"
    actions = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = [
      var.secrets.catlike_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "execution_catlike_secret" {
  role       = aws_iam_role.execution_catlike.name
  policy_arn = aws_iam_policy.execution_secret_catlike.arn
}

resource "aws_iam_policy" "execution_secret_doglike" {
  name   = "${var.name_prefix}-doglike-execution-secret-access"
  policy = data.aws_iam_policy_document.execution_secret_doglike.json
}

data "aws_iam_policy_document" "execution_secret_doglike" {
  statement {
    sid     = "SecretReadDoglike"
    actions = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = [
      var.secrets.doglike_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "execution_doglike_secret" {
  role       = aws_iam_role.execution_doglike.name
  policy_arn = aws_iam_policy.execution_secret_doglike.arn
}

# Allow optional extra policies on task roles
resource "aws_iam_role_policy_attachment" "task_extra_cat" {
  for_each   = toset(var.task_role_additional_policies)
  role       = aws_iam_role.task_catlike.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "task_extra_dog" {
  for_each   = toset(var.task_role_additional_policies)
  role       = aws_iam_role.task_doglike.name
  policy_arn = each.value
}

# Task definitions
locals {
  image_to_use = coalesce(var.container_image, local.default_image)
  catlike_container_definition = {
    name      = "catlike"
    image     = local.image_to_use
    essential = true
    command   = ["/bin/sh", "-c", "while true; do head=$(printf '%s' \"$DUMMY_SECRET\" | cut -c1-8); echo \"$(date) $ENVTYPE secret head: $head\"; sleep 20; done"]
    environment = [
      { name = "ENVTYPE", value = "catlike" }
    ]
    secrets = [
      { name = "DUMMY_SECRET", valueFrom = var.secrets.catlike_arn }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.catlike.name
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs"
      }
    }
  }
}

# Derive secrets referenced in container definitions for each service
locals {
  catlike_secret_arns  = [for s in local.catlike_container_definition.secrets : s.valueFrom if startswith(s.valueFrom, "arn:aws:secretsmanager:")]
  doglike_secret_arns  = [for s in local.doglike_container_definition.secrets : s.valueFrom if startswith(s.valueFrom, "arn:aws:secretsmanager:")]
  catlike_secret_names = [for arn in local.catlike_secret_arns : regex("^arn:aws:secretsmanager:[^:]+:[0-9]+:secret:([^:]+)", arn)[0]]
  doglike_secret_names = [for arn in local.doglike_secret_arns : regex("^arn:aws:secretsmanager:[^:]+:[0-9]+:secret:([^:]+)", arn)[0]]

  catlike_watched_ids = distinct(concat(local.catlike_secret_arns, local.catlike_secret_names, var.extra_watched_catlike))
  doglike_watched_ids = distinct(concat(local.doglike_secret_arns, local.doglike_secret_names, var.extra_watched_doglike))
}

resource "aws_ecs_task_definition" "catlike" {
  family                   = "${var.name_prefix}-catlike"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)
  execution_role_arn       = aws_iam_role.execution_catlike.arn
  task_role_arn            = aws_iam_role.task_catlike.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([local.catlike_container_definition])
}

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
}

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

# Services
resource "aws_ecs_service" "catlike" {
  name                   = "${var.name_prefix}-catlike"
  cluster                = aws_ecs_cluster.this.id
  task_definition        = aws_ecs_task_definition.catlike.arn
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

# Helpers to build service ARNs (ecs_service resource doesn't export an arn attribute)
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  catlike_service_arn = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:service/${aws_ecs_cluster.this.name}/${aws_ecs_service.catlike.name}"
  doglike_service_arn = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:service/${aws_ecs_cluster.this.name}/${aws_ecs_service.doglike.name}"
}

# Optional autoscaling for each service
resource "aws_appautoscaling_target" "catlike" {
  count              = var.enable_service_auto_scaling ? 1 : 0
  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.catlike.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "catlike_cpu" {
  count              = var.enable_service_auto_scaling ? 1 : 0
  name               = "${var.name_prefix}-catlike-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.catlike[0].resource_id
  scalable_dimension = aws_appautoscaling_target.catlike[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.catlike[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.autoscaling_target_cpu
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

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

# Cross-account deployer role for UpdateService
resource "aws_iam_role" "deployer" {
  name               = "${var.name_prefix}-deployer"
  assume_role_policy = data.aws_iam_policy_document.deployer_trust.json
}

# -----------------------------------------------------------------------------
# EventBridge rules and Lambda functions to force new deployments on secret updates
# -----------------------------------------------------------------------------

# Catlike Lambda IAM role
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "catlike_lambda" {
  name               = "${var.name_prefix}-catlike-redeploy"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

data "aws_iam_policy_document" "catlike_lambda_inline" {
  statement {
    sid       = "EcsUpdate"
    actions   = ["ecs:UpdateService"]
    resources = [local.catlike_service_arn]
  }
  statement {
    sid       = "EcsDescribe"
    actions   = ["ecs:DescribeServices", "ecs:DescribeClusters"]
    resources = ["*"]
  }
  statement {
    sid = "Logs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "catlike_lambda" {
  name   = "${var.name_prefix}-catlike-redeploy-inline"
  role   = aws_iam_role.catlike_lambda.id
  policy = data.aws_iam_policy_document.catlike_lambda_inline.json
}

resource "aws_cloudwatch_log_group" "catlike_lambda" {
  name              = "/aws/lambda/${var.name_prefix}-catlike-redeploy"
  retention_in_days = var.log_retention_days
}

resource "aws_lambda_function" "catlike" {
  function_name    = "${var.name_prefix}-catlike-redeploy"
  role             = aws_iam_role.catlike_lambda.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.catlike_lambda_zip.output_path
  source_code_hash = data.archive_file.catlike_lambda_zip.output_base64sha256

  environment {
    variables = {
      TARGET_CLUSTER_ARN = aws_ecs_cluster.this.arn
      TARGET_SERVICE_ARN = local.catlike_service_arn
      WATCHED_SECRETS    = jsonencode(local.catlike_watched_ids)
    }
  }
}

data "archive_file" "catlike_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/handler.py"
  output_path = "${path.module}/.build/${var.name_prefix}-catlike-redeploy.zip"
}

# Doglike Lambda IAM role/policy
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
    sid = "Logs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
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

data "archive_file" "doglike_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/handler.py"
  output_path = "${path.module}/.build/${var.name_prefix}-doglike-redeploy.zip"
}

# Lambda code (inline, small): parse event, validate secretId, call ecs force new deployment
# lambda source lives in lambda/handler.py

# EventBridge rules per service
resource "aws_cloudwatch_event_rule" "catlike" {
  name = "${var.name_prefix}-catlike-redeploy"
  event_pattern = jsonencode({
    source      = ["aws.secretsmanager"],
    detail-type = ["AWS API Call via CloudTrail"],
    detail = {
      eventSource = ["secretsmanager.amazonaws.com"],
      eventName   = ["PutSecretValue", "UpdateSecretVersionStage", "RotateSecret"],
      requestParameters = {
        secretId = local.catlike_watched_ids
      }
    }
  })
}

resource "aws_cloudwatch_event_rule" "doglike" {
  name = "${var.name_prefix}-doglike-redeploy"
  event_pattern = jsonencode({
    source      = ["aws.secretsmanager"],
    detail-type = ["AWS API Call via CloudTrail"],
    detail = {
      eventSource = ["secretsmanager.amazonaws.com"],
      eventName   = ["PutSecretValue", "UpdateSecretVersionStage", "RotateSecret"],
      requestParameters = {
        secretId = local.doglike_watched_ids
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "catlike" {
  rule      = aws_cloudwatch_event_rule.catlike.name
  target_id = "catlike-lambda"
  arn       = aws_lambda_function.catlike.arn
}

resource "aws_cloudwatch_event_target" "doglike" {
  rule      = aws_cloudwatch_event_rule.doglike.name
  target_id = "doglike-lambda"
  arn       = aws_lambda_function.doglike.arn
}

resource "aws_lambda_permission" "allow_events_catlike" {
  statement_id  = "AllowExecutionFromEventBridgeCatlike"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.catlike.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.catlike.arn
}

resource "aws_lambda_permission" "allow_events_doglike" {
  statement_id  = "AllowExecutionFromEventBridgeDoglike"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.doglike.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.doglike.arn
}

data "aws_iam_policy_document" "deployer_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.secrets_account_id}:root"]
    }
  }
}

data "aws_iam_policy_document" "deployer_inline" {
  statement {
    sid = "EcsUpdateServices"
    actions = [
      "ecs:UpdateService"
    ]
    resources = [
      local.catlike_service_arn,
      local.doglike_service_arn
    ]
  }

  statement {
    sid = "EcsDescribeServices"
    actions = [
      "ecs:DescribeServices"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "deployer" {
  name   = "${var.name_prefix}-deployer-update"
  role   = aws_iam_role.deployer.id
  policy = data.aws_iam_policy_document.deployer_inline.json
}
