locals {
  deployer_roles = {
    "user-research" = "arn:aws:iam::619109835131:role/deployer-user-research"
    "dev"           = "arn:aws:iam::498160065950:role/deployer-dev"
    "staging"       = "arn:aws:iam::972536609845:role/deployer-staging"
    "production"    = "arn:aws:iam::443944947292:role/deployer-production"
  }

  environment_variables = {
    "DEPLOYER_ROLE_ARN" = lookup(local.deployer_roles, var.environment)
    "ENVIRONMENT"       = var.environment
    "TERRAFORM_VERSION" = var.terraform_version
  }

  deploy_directory = {
    "dev" = "development"
  }
}

resource "aws_codebuild_project" "this" {
  #checkov:skip=CKV_AWS_147:Amazon Managed SSE is sufficient.
  name         = var.project_name
  description  = var.project_description
  service_role = var.codebuild_service_role_arn

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.log_group.name
      stream_name = "terraform"
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"

    # Create environment variables dynamically. 
    # We use local variables by default but they can be overriden by var.environment_variables
    dynamic "environment_variable" {
      for_each = merge(local.environment_variables, var.environment_variables)

      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec
  }
}
