locals {
  default_image = "public.ecr.aws/docker/library/busybox:latest"
}

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

# Common image local
locals {
  image_to_use = coalesce(var.container_image, local.default_image)
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

# Cross-account deployer role for UpdateService (trust + inline policy references per-service locals)
resource "aws_iam_role" "deployer" {
  name               = "${var.name_prefix}-deployer"
  assume_role_policy = data.aws_iam_policy_document.deployer_trust.json
}

data "aws_iam_policy_document" "deployer_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.secrets_account_id}:root"]
    }
  }
}

data "aws_iam_policy_document" "deployer_inline" {
  statement {
    sid     = "EcsUpdateServices"
    actions = ["ecs:UpdateService"]
    resources = [
      local.catlike_service_arn,
      local.doglike_service_arn
    ]
  }

  statement {
    sid       = "EcsDescribeServices"
    actions   = ["ecs:DescribeServices"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "deployer" {
  name   = "${var.name_prefix}-deployer-update"
  role   = aws_iam_role.deployer.id
  policy = data.aws_iam_policy_document.deployer_inline.json
}
