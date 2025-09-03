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

module "all_accounts" {
  source = "../../modules/all-accounts"
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

# Note: EventBridge bus policy to allow deploy account is created
# by forms/pipelines/eventbridge.tf and is not needed here
