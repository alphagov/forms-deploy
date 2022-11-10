resource "aws_iam_role" "task_role" {
  name = "${var.env_name}-${var.application}-iam_for_ecs_task"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Base policy attached to all tasks
data "aws_iam_policy_document" "standard_ecs_app" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecs_task_policy" {
  name   = "ecs_task_policy"
  role   = aws_iam_role.task_role.name
  policy = data.aws_iam_policy_document.standard_ecs_app.json
}

## Attaches additonal optional inline IAM policy to this task's role
#resource "aws_iam_role_policy" "additional_task_policy" {
#  count  = var.additional_policy_json == "" ? 0 : 1
#  name   = "ecs_task_additional_policy"
#  role   = aws_iam_role.task_role.name
#  policy = var.additional_policy_json
#}

resource "aws_iam_role" "task_exec_role" {
  name = "${var.env_name}-${var.application}-iam_for_ecs_exec_ssm"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_standard_policy" {
  role       = aws_iam_role.task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_task_exec_policy" {
  name = "parameter_store_exec_policy"
  role = aws_iam_role.task_exec_role.name

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
