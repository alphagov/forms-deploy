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

resource "aws_iam_role" "github_actions" {
  for_each = local.github_actions_apps

  name        = "review-github-actions-${each.key}"
  description = "Role assumed by GitHub Actions workflows for ${each.key} review apps"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = data.terraform_remote_state.account.outputs.github_oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:alphagov/${each.key}:pull_request"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "github_actions" {
  for_each = local.github_actions_apps

  role   = aws_iam_role.github_actions[each.key].name
  policy = data.aws_iam_policy_document.github_actions[each.key].json
}

data "aws_iam_policy_document" "github_actions" {
  for_each = local.github_actions_apps

  statement {
    sid    = "UseECSServices"
    effect = "Allow"
    actions = [
      "ecs:*Service",
      "ecs:*Services",
      "ecs:TagResource"
    ]
    resources = [
      aws_ecs_cluster.review.arn,
      "arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:service/${aws_ecs_cluster.review.name}/${each.key}-pr-*"
    ]
  }

  statement {
    sid    = "UseECSTaskDefinitions"
    effect = "Allow"
    actions = [
      "ecs:*TaskDefinition",
      "ecs:*TaskDefinitions",
      "ecs:TagResource"
    ]
    resources = [
      "arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:task-definition/${each.key}-pr-*"
    ]
  }

  statement {
    sid    = "AllowTaskDefinitionsNeedingStar"
    effect = "Allow"
    actions = [
      "ecs:DeregisterTaskDefinition",
      "ecs:DescribeTaskDefinition"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ReadTerraformStateFiles"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:HeadObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::gds-forms-integration-tfstate",
      "arn:aws:s3:::gds-forms-integration-tfstate/review.tfstate",
      "arn:aws:s3:::gds-forms-integration-tfstate/review-apps/${each.key}/pr-*.tfstate"
    ]
  }

  statement {
    sid    = "WriteTerraformStateFiles"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectVersion"
    ]
    resources = [
      "arn:aws:s3:::gds-forms-integration-tfstate/review-apps/${each.key}/pr-*.tfstate"
    ]
  }

  statement {
    sid = "ReleaseTerraformStateLock"
    actions = [
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::gds-forms-integration-tfstate/review-apps/${each.key}/pr-*.tflock"
    ]
    effect = "Allow"
  }

  statement {
    sid    = "UseLocalECR"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = [
      each.value.ecr_repository_arn
    ]
  }

  statement {
    sid    = "LogIntoLocalECR"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "UseDeployECR"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]
    resources = [
      "arn:aws:ecr:eu-west-2:${var.deploy_account_id}:repository/*"
    ]
  }

  statement {
    sid    = "AllowIAMPassRole"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      aws_iam_role.ecs_execution.arn,
      aws_iam_service_linked_role.app_autoscaling.arn,
    ]
  }

  statement {
    sid    = "UseAppAutoscaling"
    effect = "Allow"
    actions = [
      "application-autoscaling:*ScalableTarget",
      "application-autoscaling:*ScalableTargets",
      "application-autoscaling:*ScheduledAction",
      "application-autoscaling:*ScheduledActions",
      "application-autoscaling:*ScalingPolicy",
      "application-autoscaling:*ScalingPolicies",
      "application-autoscaling:ListTagsForResource",
      "application-autoscaling:TagResource",
      "application-autoscaling:UntagResource"
    ]
    resources = [
      "arn:aws:application-autoscaling:eu-west-2:${data.aws_caller_identity.current.account_id}:scalable-target/*"
    ]
  }

  statement {
    sid    = "UseAppAutoscalingNeedingStar"
    effect = "Allow"
    actions = [
      "application-autoscaling:DescribeScalableTargets",
      "application-autoscaling:DescribeScalingPolicies",
      "application-autoscaling:DescribeScheduledActions",
    ]
    resources = [
      "*"
    ]
  }
}
