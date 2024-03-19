data "aws_caller_identity" "current" {}

locals {
  deploy_account_id = "711966560482"
  aws_account_id    = data.aws_caller_identity.current.account_id
  project_name      = "${var.app_name}-e2e-tests-${var.environment_name}"
}

resource "aws_codebuild_project" "e2e" {
  #checkov:skip=CKV_AWS_147:Amazon Managed SSE is sufficient.
  name         = local.project_name
  description  = "Run end to end tests for ${var.app_name} in ${var.environment_name}"
  service_role = coalesce(var.service_role_arn, try(aws_iam_role.codebuild[0].arn, null))

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.log_group.name
      stream_name = "e2e"
    }
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "711966560482.dkr.ecr.eu-west-2.amazonaws.com/end-to-end-tests:latest"
    type         = "LINUX_CONTAINER"

    image_pull_credentials_type = "SERVICE_ROLE"

    environment_variable {
      name  = "AUTH0_EMAIL_USERNAME"
      value = var.auth0_user_name_parameter_name
      type  = "PARAMETER_STORE"
    }

    environment_variable {
      name  = "AUTH0_USER_PASSWORD"
      value = var.auth0_user_password_parameter_name
      type  = "PARAMETER_STORE"
    }

    environment_variable {
      name  = "SETTINGS__GOVUK_NOTIFY__API_KEY"
      value = var.notify_api_key_parameter_name
      type  = "PARAMETER_STORE"
    }

    environment_variable {
      name  = "FORMS_ADMIN_URL"
      value = var.forms_admin_url
    }

    environment_variable {
      name  = "PRODUCT_PAGES_URL"
      value = var.product_pages_url
    }

    environment_variable {
      name  = "LOG_LEVEL"
      value = "debug"
    }

    environment_variable {
      name  = "TRACE"
      value = "1"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec/buildspec.yml")
  }
}
