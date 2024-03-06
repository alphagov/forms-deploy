data "aws_caller_identity" "current" {}

resource "aws_iam_role" "codepipeline_readonly" {
  name = "codepipeline-readonly"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.pipeline_visualiser_task.arn
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_readonly_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_ReadOnlyAccess"
  role       = aws_iam_role.codepipeline_readonly.name
}

resource "aws_iam_role" "pipeline_visualiser_task" {
  name = "deploy-pipeline-visualiser-ecs-task"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "allow_pipeline_visualiser_to_assume_roles" {
  role = aws_iam_role.pipeline_visualiser_task.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowAssumeRole"
        Action   = "sts:AssumeRole"
        Effect   = "Allow"
        Resource = ["arn:aws:iam::*:role/codepipeline-readonly"]
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_exec_role" {
  name        = "tools-ecs-task-execution"
  description = "Used by ECS to create ECS tasks"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_standard_policy" {
  role       = aws_iam_role.ecs_task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
