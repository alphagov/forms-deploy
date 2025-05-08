data "aws_caller_identity" "current" {}

##
# IAM
##
resource "aws_iam_role" "github_actions_runner" {
  name        = "review-github-actions-runner-${var.application_name}"
  description = "Role assumed by the CodeBuild-hosted GitHuB Actions runner for ${var.application_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "runner_permissions" {
  role   = aws_iam_role.github_actions_runner.name
  policy = data.aws_iam_policy_document.runner_permissions.json
}

data "aws_iam_policy_document" "runner_permissions" {
  # This IAM policy is being used in a role which
  # is being operated from a public GitHub repository.
  #
  # It must be carefully locked down to doing only
  # the things we need to allow it to do.

  statement {
    sid    = "UseCodeConnection"
    effect = "Allow"
    actions = [
      "codeconnections:GetConnectionToken",
      "codeconnections:GetConnection",
    ]
    resources = [var.codestar_connection_arn]
  }

  statement {
    sid    = "UseECSServices"
    effect = "Allow"
    actions = [
      "ecs:*Service",
      "ecs:*Services",
      "ecs:TagResource"
    ]
    resources = [
      var.aws_ecs_cluster_arn,
      "arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:service/${var.aws_ecs_cluster_name}/${var.application_name}-pr-*"
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
      "arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:task-definition/${var.application_name}-pr-*"
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
      "arn:aws:s3:::gds-forms-integration-tfstate/review-apps/${var.application_name}/pr-*.tfstate"
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
      "arn:aws:s3:::gds-forms-integration-tfstate/review-apps/${var.application_name}/pr-*.tfstate"
    ]
  }

  statement {
    sid = "ReleaseTerraformStateLock"
    actions = [
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::gds-forms-integration-tfstate/review-apps/${var.application_name}/pr-*.tflock"
    ]
    effect = "Allow"
  }

  statement {
    sid    = "UseLocalECR"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = [
      var.aws_ecr_repository_arn
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
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer"
    ]
    resources = [
      "arn:aws:ecr:eu-west-2:${var.deploy_account_id}:repository/*"
    ]
  }

  statement {
    sid    = "UseCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
    ]
    resources = [
      "arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/*"
    ]
  }

  statement {
    sid    = "AllowIAMPassRole"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      var.task_execution_role_arn,
      var.autoscaling_role_arn,
    ]
  }

  statement {
    sid    = "AllowDockerCredAccess"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
    resources = [
      var.dockerhub_password_parameter_arn,
      var.dockerhub_username_parameter_arn,
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

##
# CodeBuild
##
resource "aws_codebuild_project" "github_actions_runner" {
  # checkov:skip=CKV_AWS_314:The logs for the project will be reflected in GitHub Actions
  name         = "review-${var.application_name}-gha-runner"
  service_role = aws_iam_role.github_actions_runner.arn

  build_timeout = 15

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-aarch64-standard:3.0"
    type                        = "ARM_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "DOCKER_USERNAME"
      value = "/${provider::aws::arn_parse(var.dockerhub_username_parameter_arn).resource}"
      type  = "PARAMETER_STORE"
    }

    environment_variable {
      name  = "DOCKER_PASSWORD"
      value = "/${provider::aws::arn_parse(var.dockerhub_password_parameter_arn).resource}"
      type  = "PARAMETER_STORE"
    }
  }

  source {
    type     = "GITHUB"
    location = var.application_source_repository

    auth {
      type     = "CODECONNECTIONS"
      resource = var.codestar_connection_arn
    }
  }
}

resource "aws_codebuild_webhook" "github_webhook" {
  project_name = aws_codebuild_project.github_actions_runner.name
  build_type   = "BUILD"

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "WORKFLOW_JOB_QUEUED"
    }
  }
}
