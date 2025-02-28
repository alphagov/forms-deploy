data "aws_caller_identity" "current" {}

##
# At the time this code was written it wasn't possible to configure
# a GitHub Actions runner on AWS CodeBuild via Terraform because of
# some missing configuration options in the AWS Terraform provider.
#
# Instead this Terraform sets up everything except the source configuration
# in CodeBuild, and a post-apply script configures that, using outputs from this.
##

##
# IAM
##
resource "aws_iam_role" "github_actions_runner" {
  name        = "review-github-actions-runner"
  description = "Role assumed by the CodeBuild-hosted GitHuB Actions runner"

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

resource "aws_iam_service_linked_role" "app_autoscaling" {
  aws_service_name = "ecs.application-autoscaling.amazonaws.com"
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
    resources = [data.terraform_remote_state.account.outputs.codeconnection_arn]
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
      aws_ecs_cluster.review.arn,
      "arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:service/${aws_ecs_cluster.review.name}/forms-admin-pr-*"
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
      "arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:task-definition/forms-admin-pr-*"
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
      "arn:aws:s3:::gds-forms-integration-tfstate/review-apps/forms-admin/pr-*.tfstate"
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
      "arn:aws:s3:::gds-forms-integration-tfstate/review-apps/forms-admin/pr-*.tfstate"
    ]
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
      module.forms_admin_container_repo.arn
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
      aws_iam_role.ecs_execution.arn,
      aws_iam_service_linked_role.app_autoscaling.arn
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
      aws_ssm_parameter.dockerhub_password.arn,
      aws_ssm_parameter.dockerhub_username.arn
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
resource "aws_codebuild_project" "forms_admin_github_actions_runner" {
  # checkov:skip=CKV_AWS_314:The logs for the project will be reflected in GitHub Actions
  name         = "review-forms-admin-gha-runner"
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
      value = aws_ssm_parameter.dockerhub_username.name
      type  = "PARAMETER_STORE"
    }

    environment_variable {
      name  = "DOCKER_PASSWORD"
      value = aws_ssm_parameter.dockerhub_password.name
      type  = "PARAMETER_STORE"
    }
  }

  # This is a placeholder configuration.
  # post-apply.sh updates the Terraform-configured
  # resources, because the Terraform provider does
  # not support those options
  source {
    type     = "GITHUB"
    location = "https://github.com/alphagov/forms-admin"
  }

  lifecycle {
    # ignore changes to the source block so that
    # this and post-apply.sh aren't fighting over it.
    ignore_changes = [source]
  }
}

resource "aws_codebuild_webhook" "github_webhook" {
  project_name = aws_codebuild_project.forms_admin_github_actions_runner.name
  build_type   = "BUILD"

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "WORKFLOW_JOB_QUEUED"
    }
  }
}

resource "aws_codebuild_source_credential" "github_credential" {
  auth_type   = "CODECONNECTIONS" # this is a valid value, but is not documented at the time of writing (2025-02-12)
  server_type = "GITHUB"

  # This is the correct token value when auth_type=CODECONNECTIONS.
  # It is supported, but not documented, at the time of writing (2025-02-12)
  token = data.terraform_remote_state.account.outputs.codeconnection_arn
}
