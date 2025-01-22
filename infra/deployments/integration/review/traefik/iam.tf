resource "aws_iam_role" "ecs_execution" {
  name               = "review-traefik-ecs-execution"
  description        = "The role assumed by AWS ECS when starting Traefik tasks in the review environment"
  assume_role_policy = data.aws_iam_policy_document.allow_ecs_to_assume_role.json
}

resource "aws_iam_role" "ecs_task" {
  name               = "review-traefik-ecs-task"
  description        = "The role assumed by AWS ECS when running Traefik tasks"
  assume_role_policy = data.aws_iam_policy_document.allow_ecs_to_assume_role.json
}

data "aws_iam_policy_document" "allow_ecs_to_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "traefik_ecs_permissions" {
  #checkov:skip=CKV_AWS_356:Traefik has read-only permission, and some of those require resource *

  name        = "review-treafik-ecs-permissions"
  description = "The permissions, granted to Traefik, to read information about ECS"
  policy      = data.aws_iam_policy_document.traefik_ecs_permissions.json
}

resource "aws_iam_role_policy_attachment" "traefik_ecs" {
  policy_arn = aws_iam_policy.traefik_ecs_permissions.arn
  role       = aws_iam_role.ecs_task.name
}

data "aws_iam_policy_document" "traefik_ecs_permissions" {
  statement {
    sid = "AllowECSDiscovery"
    actions = [
      "ecs:ListClusters",
      "ecs:DescribeClusters",
      "ecs:ListTasks",
      "ecs:DescribeTasks",
      "ecs:DescribeContainerInstances",
      "ecs:DescribeTaskDefinition",
      "ec2:DescribeInstances",
      "ssm:DescribeInstanceInformation"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_standard_policy" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
