resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.env_name}-${var.application}-ecs-task"
  description        = "Used by ${var.application} tasks when running"
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

resource "aws_iam_role" "ecs_task_exec_role" {
  name               = "${var.env_name}-${var.application}-ecs-task-execution"
  description        = "Used by ECS to create ${var.application} task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_exec_role_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_exec_role_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_standard_policy" {
  role       = aws_iam_role.ecs_task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_additional_policies" {
  role       = aws_iam_role.ecs_task_exec_role.name
  policy_arn = aws_iam_policy.ecs_task_exec_additional_policy.arn
}

resource "aws_iam_policy" "ecs_task_exec_additional_policy" {
  name   = "${var.env_name}-${var.application}-ecs-task-execution-additional"
  policy = data.aws_iam_policy_document.ecs_task_exec_additional_policies.json
}

data "aws_iam_policy_document" "ecs_task_exec_additional_policies" {
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
      "arn:aws:ssm:*:*:parameter/${var.application}-${var.env_name}/*"
    ]
    effect = "Allow"
  }
}
