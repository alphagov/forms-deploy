locals {
  deployer_roles = {
    "user-research" = "arn:aws:iam::619109835131:role/deployer-user-research"
    "dev"           = "arn:aws:iam::498160065950:role/deployer-dev"
    "staging"       = "arn:aws:iam::972536609845:role/deployer-staging"
    "production"    = "arn:aws:iam::443944947292:role/deployer-production"
  }

  project_name = "${var.app_name}-deploy-${var.environment}${var.project_name_suffix}"

  deploy_directory = {
    "dev" = "development"
  }
}

resource "aws_codebuild_project" "terraform" {
  #checkov:skip=CKV_AWS_147:Amazon Managed SSE is sufficient.
  name         = local.project_name
  description  = "Run terraform apply for ${var.app_name} in ${var.environment}"
  service_role = aws_iam_role.codebuild.arn

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

    environment_variable {
      name  = "DEPLOYER_ROLE_ARN"
      value = lookup(local.deployer_roles, var.environment)
    }
    environment_variable {
      name  = "TERRAFORM_VERSION"
      value = var.terraform_version
    }
    environment_variable {
      name  = "CLUSTER_NAME"
      value = "forms-${var.environment}"
    }
    environment_variable {
      name  = "SERVICE_NAME"
      value = var.app_name
    }
    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }
    environment_variable {
      name  = "MAX_WAIT_TIME_SECONDS"
      value = "600"
    }
    environment_variable {
      name  = "DEPLOYMENT_UPDATE_POLLING_SECONDS"
      value = "5"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec/buildspec.yml")
  }
}
