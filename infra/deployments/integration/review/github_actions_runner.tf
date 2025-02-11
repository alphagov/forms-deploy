data "aws_caller_identity" "current" {}

##
# At the time this code was written it wasn't possible to configure
# a GitHub Actions runner on AWS CodeBuild via Terraform because of
# some missing configuration options in the AWS Terraform provider.
#
# Instead this Terraform sets up everything except CodeBuild, and a
# post-apply script creates that, using outputs from this.
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
    sid = "UseCodeConnection"
    effect = "Allow"
    actions = [
      "codeconnections:GetConnectionToken",
      "codeconnections:GetConnection",
    ]
    resources = [data.terraform_remote_state.account.outputs.codeconnection_arn]
  }

  statement {
    sid = "UseECSServices"
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
    sid = "UseECSTaskDefinitions"
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
    sid = "ReadTerraformStateFiles"
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
    sid = "WriteTerraformStateFiles"
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
    sid = "UseLocalECR"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:GetAuthorizationToken",
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
    sid = "UseDeployECR"
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
}
