resource "aws_iam_role" "ecs_execution" {
  name               = "review-apps-ecs-execution"
  description        = "The role assumed by AWS ECS when starting review app tasks in the review environment"
  assume_role_policy = data.aws_iam_policy_document.allow_ecs_to_assume_role.json
}

resource "aws_iam_service_linked_role" "app_autoscaling" {
  aws_service_name = "ecs.application-autoscaling.amazonaws.com"
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_standard_policy" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
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
