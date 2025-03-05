locals {
  execution_role_name   = "${var.environment}-bastion-ecs-task-execution"
  execution_policy_name = "${var.environment}-bastion-ecs-task-execution-additional"
  execution_policy_arn  = "arn:aws:iam::${var.account_id}:policy/${local.execution_policy_name}"
  task_role_name        = "${var.environment}-bastion-ecs-task"
  task_policy_name      = "${var.environment}-bastion-ecs-task-policy"
  task_policy_arn       = "arn:aws:iam::${var.account_id}:policy/${local.task_policy_name}"
}

resource "aws_iam_role" "ecs_bastion_task_role" {
  name        = local.task_role_name
  description = "Used by bastion host when running"

  assume_role_policy = data.aws_iam_policy_document.ecs_bastion_task_role_assume_role.json
}

data "aws_iam_policy_document" "ecs_bastion_task_role_assume_role" {
  statement {
    sid     = "AllowECS"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_bastion_task_exec_role" {
  name        = local.execution_role_name
  description = "Used by ECS to create bastion host task"

  assume_role_policy = data.aws_iam_policy_document.ecs_bastion_task_exec_role_assume_role.json
}

data "aws_iam_policy_document" "ecs_bastion_task_exec_role_assume_role" {
  statement {
    sid     = "AllowECS"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_bastion_task_policy" {
  role       = aws_iam_role.ecs_bastion_task_role.name
  policy_arn = aws_iam_policy.ecs_bastion_task_policy.arn
}

resource "aws_iam_policy" "ecs_bastion_task_policy" {
  name        = local.task_policy_name
  description = "Used by bastion host when running"
  policy      = data.aws_iam_policy_document.ecs_bastion_task_policy.json
}

data "aws_iam_policy_document" "ecs_bastion_task_policy" {
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_bastion_task_exec_policy" {
  role       = aws_iam_role.ecs_bastion_task_exec_role.name
  policy_arn = aws_iam_policy.ecs_bastion_task_exec_policy.arn
}

resource "aws_iam_policy" "ecs_bastion_task_exec_policy" {
  name   = local.execution_policy_name
  policy = data.aws_iam_policy_document.ecs_bastion_task_exec_policy.json
}

data "aws_iam_policy_document" "ecs_bastion_task_exec_policy" {
  statement {
    actions = [
      "ssm:DescribeParameters"
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "ssm:GetParameters"
    ]
    resources = [
      for database, ssm_parameter in data.aws_ssm_parameter.database_url_secrets :
      ssm_parameter.arn
    ]
    effect = "Allow"
  }
}
