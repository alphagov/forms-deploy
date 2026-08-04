data "aws_caller_identity" "current" {}

locals {
  basic_auth_username_parameter_arn   = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/tempo-${var.env_name}/basic-auth/username"
  basic_auth_password_parameter_arn   = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/tempo-${var.env_name}/basic-auth/password"
  github_datasource_pat_parameter_arn = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/tempo-${var.env_name}/github-datasource/pat"
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
      local.github_datasource_pat_parameter_arn,
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

resource "aws_iam_role" "mimir_task" {
  name               = "${var.env_name}-tempo-mimir-ecs-task"
  description        = "Used by the mimir task when running"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_assume_role.json
}

resource "aws_iam_role" "mimir_task_exec" {
  name               = "${var.env_name}-tempo-mimir-ecs-task-execution"
  description        = "Used by ECS to create the mimir task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_assume_role.json
}

resource "aws_iam_role_policy_attachment" "mimir_task_exec_standard_policy" {
  role       = aws_iam_role.mimir_task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
# No additional execution-role policy needed - unlike grafana, mimir reads
# no SSM secrets. mimir_task's S3 access policy is attached in s3.tf.

resource "aws_iam_role" "alloy_task" {
  name               = "${var.env_name}-tempo-alloy-ecs-task"
  description        = "Used by the alloy task when running"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_assume_role.json
}

resource "aws_iam_role" "alloy_task_exec" {
  name               = "${var.env_name}-tempo-alloy-ecs-task-execution"
  description        = "Used by ECS to create the alloy task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_assume_role.json
}

resource "aws_iam_role_policy_attachment" "alloy_task_exec_standard_policy" {
  role       = aws_iam_role.alloy_task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
# No additional task or execution-role policy needed - alloy touches no
# AWS APIs directly in this design (S3/Mimir/Tempo access are all plain
# network calls over the internal ALB, not AWS API calls).
