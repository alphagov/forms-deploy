locals {
  deployer_roles = {
    "dev"        = "arn:aws:iam::498160065950:role/deployer-dev"
    "staging"    = "arn:aws:iam::972536609845:role/deployer-staging"
    "production" = "arn:aws:iam::443944947292:role/deployer-production"
  }

  project_name = "${var.app_name}-deploy-${var.environment}"

  deploy_directory = {
    "dev" = "development"
  }
}

resource "aws_codebuild_project" "terraform" {
  #checkov:skip=CKV_AWS_147:Amazon Managed SSE is sufficient.
  name         = local.project_name
  description  = "Run terraform apply for ${var.app_name} in ${var.environment}"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "DEPLOYER_ROLE_ARN"
      value = lookup(local.deployer_roles, var.environment)
    }
    environment_variable {
      name  = "DEPLOY_DIRECTORY"
      value = "infra/deployments/${lookup(local.deploy_directory, var.environment, var.environment)}/${var.app_name}"
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
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec/buildspec.yml")
  }
}
