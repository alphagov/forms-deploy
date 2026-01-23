data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  github_actions_apps = {
    "forms-admin" = {
      ecr_repository_arn = module.forms_admin_container_repo.arn
    }
    "forms-runner" = {
      ecr_repository_arn = module.forms_runner_container_repo.arn
    }
    "forms-product-page" = {
      ecr_repository_arn = module.forms_product_page_container_repo.arn
    }
  }
}

# S3 bucket for CodeBuild artifacts (terraform outputs)
module "codebuild_artifacts" {
  source = "../../../modules/secure-bucket"

  name                   = "forms-review-codebuild-artifacts"
  versioning_enabled     = false
  access_logging_enabled = false
}

resource "aws_s3_bucket_lifecycle_configuration" "codebuild_artifacts" {
  bucket = module.codebuild_artifacts.name

  rule {
    id     = "expire-old-artifacts"
    status = "Enabled"

    filter {}

    expiration {
      days = 1
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

# CodeBuild projects for each app
module "codebuild_deploy" {
  for_each = local.github_actions_apps
  source   = "./review-app-codebuild"

  application_name        = each.key
  action                  = "deploy"
  github_repository       = "https://github.com/alphagov/${each.key}"
  codeconnection_arn      = data.terraform_remote_state.account.outputs.codeconnection_arn
  artifacts_bucket_name   = module.codebuild_artifacts.name
  ecs_cluster_arn         = aws_ecs_cluster.review.arn
  ecs_cluster_name        = aws_ecs_cluster.review.name
  ecr_repository_arn      = each.value.ecr_repository_arn
  task_execution_role_arn = aws_iam_role.ecs_execution.arn
  autoscaling_role_arn    = aws_iam_service_linked_role.app_autoscaling.arn
  deploy_account_id       = var.deploy_account_id
}

module "codebuild_destroy" {
  for_each = local.github_actions_apps
  source   = "./review-app-codebuild"

  application_name        = each.key
  action                  = "destroy"
  github_repository       = "https://github.com/alphagov/${each.key}"
  codeconnection_arn      = data.terraform_remote_state.account.outputs.codeconnection_arn
  artifacts_bucket_name   = module.codebuild_artifacts.name
  ecs_cluster_arn         = aws_ecs_cluster.review.arn
  ecs_cluster_name        = aws_ecs_cluster.review.name
  ecr_repository_arn      = each.value.ecr_repository_arn
  task_execution_role_arn = aws_iam_role.ecs_execution.arn
  autoscaling_role_arn    = aws_iam_service_linked_role.app_autoscaling.arn
  deploy_account_id       = var.deploy_account_id
}

# OIDC roles with minimal permissions (trigger CodeBuild + push to ECR)
data "aws_iam_policy_document" "github_actions_assume_role" {
  for_each = local.github_actions_apps

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.terraform_remote_state.account.outputs.github_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:alphagov/${each.key}:pull_request"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  for_each = local.github_actions_apps

  name        = "review-github-actions-${each.key}"
  description = "Role assumed by GitHub Actions workflows for ${each.key} review apps"

  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role[each.key].json
}

resource "aws_iam_role_policy" "github_actions" {
  for_each = local.github_actions_apps

  role   = aws_iam_role.github_actions[each.key].name
  policy = data.aws_iam_policy_document.github_actions[each.key].json
}

data "aws_iam_policy_document" "github_actions" {
  for_each = local.github_actions_apps

  # Trigger CodeBuild projects
  statement {
    sid     = "TriggerCodeBuild"
    actions = ["codebuild:StartBuild", "codebuild:BatchGetBuilds"]
    resources = [
      module.codebuild_deploy[each.key].project_arn,
      module.codebuild_destroy[each.key].project_arn
    ]
  }

  # Read CodeBuild logs
  statement {
    sid     = "ReadCodeBuildLogs"
    actions = ["logs:GetLogEvents"]
    resources = [
      module.codebuild_deploy[each.key].log_group_arn,
      module.codebuild_destroy[each.key].log_group_arn
    ]
  }

  # Push container images to ECR
  statement {
    sid = "PushToECR"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = [each.value.ecr_repository_arn]
  }

  statement {
    sid       = "ECRLogin"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  # Wait for ECS service stability (read-only)
  statement {
    sid     = "WaitForECSStability"
    actions = ["ecs:DescribeServices"]
    resources = [
      "arn:aws:ecs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:service/${aws_ecs_cluster.review.name}/${each.key}-pr-*"
    ]
  }

  # Read and delete CodeBuild artifacts (terraform outputs)
  statement {
    sid     = "ReadArtifacts"
    actions = ["s3:GetObject", "s3:DeleteObject"]
    resources = [
      "${module.codebuild_artifacts.arn}/*/review-${each.key}-deploy/outputs.json"
    ]
  }
}
