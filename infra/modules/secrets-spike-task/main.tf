# Per-environment ECS clusters are defined in catlike.tf and doglike.tf

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

# Helpers to build service ARNs (ecs_service resource doesn't export an arn attribute)
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Common image local - always use busybox
locals {
  image_to_use = "public.ecr.aws/docker/library/busybox:latest"
}

# Lambda assume role policy (shared)
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Default bus policy to allow deploy account to put events
resource "aws_cloudwatch_event_bus_policy" "allow_deploy_put" {
  event_bus_name = "default"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowDeployAccountPutEvents"
        Effect    = "Allow"
        Principal = { "AWS" = "arn:aws:iam::${var.secrets_account_id}:root" }
        Action    = "events:PutEvents"
        Resource  = "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:event-bus/default"
      }
    ]
  })
}
