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

resource "aws_iam_role_policy" "ecs_task_exec_policy" {
  name = "parameter_store_exec_policy"
  role = aws_iam_role.ecs_task_exec_role.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "ssm:DescribeParameters"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters"
      ],
      "Resource": [
        "arn:aws:ssm:*:*:parameter/${var.application}-${var.env_name}/*"
      ]
    }
  ]
}
EOF
}
