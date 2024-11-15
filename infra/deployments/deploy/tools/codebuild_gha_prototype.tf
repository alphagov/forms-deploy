resource "aws_codebuild_project" "github_actions_runner" {
  name = "githubRunner"
  description = "AWS CodeBuild-hosted GitHub Actions runner"
  service_role = aws_iam_role.github_actions_runner.arn
  build_timeout = 10

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type = "GITHUB_ENTERPRISE" #NOTE: Not GITHUB. Only GITHUB_ENTERPRISE supports CodeStar Connections.
    location = "https://github.com/alphagov/forms-deploy"
    git_clone_depth = 1
  }
}

resource "aws_codebuild_webhook" "github_webhooks" {
  project_name = aws_codebuild_project.github_actions_runner.name
  build_type = "BUILD"

  filter_group {
    filter {
      type = "EVENT"
      pattern = "WORKFLOW_JOB_QUEUED"
    }
  }
}

resource "aws_iam_role" "github_actions_runner" {
  name = "github-actions-runner"
  description = "Role assumed by the CodeBuild-hosted GitHub Actions runner"
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

resource "aws_iam_role_policy" "github_actions_runner_use_codestar" {
  name = "use-codestar-connection"
  role = aws_iam_role.github_actions_runner.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "codeconnections:GetConnectionToken",
          "codeconnections:GetConnection"
        ]
        Effect   = "Allow"
        Resource = var.codestar_connection_arn
      },
    ]
  })
}