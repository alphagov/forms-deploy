data "aws_caller_identity" "current" {}

locals {
  basic_auth_username_parameter_arn = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/tempo-${var.env_name}/basic-auth/username"
  basic_auth_password_parameter_arn = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/tempo-${var.env_name}/basic-auth/password"
}

resource "aws_iam_role" "tempo_task" {
  name               = "${var.env_name}-tempo-ecs-task"
  description        = "Used by the tempo/grafana task when running"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_role_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "tempo_task_exec" {
  name               = "${var.env_name}-tempo-ecs-task-execution"
  description        = "Used by ECS to create the tempo/grafana task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_assume_role.json
}

resource "aws_iam_role_policy_attachment" "tempo_task_exec_standard_policy" {
  role       = aws_iam_role.tempo_task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "tempo_task_exec_additional" {
  statement {
    actions   = ["ssm:DescribeParameters"]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = ["ssm:GetParameters"]
    resources = [
      local.basic_auth_username_parameter_arn,
      local.basic_auth_password_parameter_arn,
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "tempo_task_exec_additional" {
  name   = "${var.env_name}-tempo-ecs-task-execution-additional"
  policy = data.aws_iam_policy_document.tempo_task_exec_additional.json
}

resource "aws_iam_role_policy_attachment" "tempo_task_exec_additional" {
  role       = aws_iam_role.tempo_task_exec.name
  policy_arn = aws_iam_policy.tempo_task_exec_additional.arn
}

resource "aws_iam_role" "prometheus_task" {
  name               = "${var.env_name}-tempo-prometheus-ecs-task"
  description        = "Used by the prometheus task when running"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_assume_role.json
}

resource "aws_iam_role" "prometheus_task_exec" {
  name               = "${var.env_name}-tempo-prometheus-ecs-task-execution"
  description        = "Used by ECS to create the prometheus task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_assume_role.json
}

resource "aws_iam_role_policy_attachment" "prometheus_task_exec_standard_policy" {
  role       = aws_iam_role.prometheus_task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
# No additional execution-role policy needed - unlike grafana, prometheus
# reads no SSM secrets.

data "aws_iam_policy_document" "prometheus_task_efs_access" {
  statement {
    effect = "Allow"
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
    ]
    resources = [aws_efs_file_system.prometheus.arn]

    condition {
      test     = "StringEquals"
      variable = "elasticfilesystem:AccessPointArn"
      values   = [aws_efs_access_point.prometheus.arn]
    }
  }
}

resource "aws_iam_policy" "prometheus_task_efs_access" {
  name   = "${var.env_name}-tempo-prometheus-efs-access"
  policy = data.aws_iam_policy_document.prometheus_task_efs_access.json
}

resource "aws_iam_role_policy_attachment" "prometheus_task_efs_access" {
  role       = aws_iam_role.prometheus_task.name
  policy_arn = aws_iam_policy.prometheus_task_efs_access.arn
}
