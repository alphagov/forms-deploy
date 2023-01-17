data "aws_caller_identity" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  project_name   = "${var.app_name}-smoke-tests-${var.environment}"
}

resource "aws_codebuild_project" "smoke_tests" {
  #checkov:skip=CKV_AWS_147:Amazon Managed SSE is sufficient.
  name         = local.project_name
  description  = "Run smoke tests for ${var.app_name} in ${var.environment}"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "SIGNON_USERNAME"
      value = "/${var.environment}/smoketests/signon/username"
      type  = "PARAMETER_STORE"
    }

    environment_variable {
      name  = "SIGNON_PASSWORD"
      value = "/${var.environment}/smoketests/signon/password"
      type  = "PARAMETER_STORE"
    }

    environment_variable {
      name  = "SIGNON_OTP"
      value = "/${var.environment}/smoketests/signon/secret"
      type  = "PARAMETER_STORE"
    }

    environment_variable {
      name  = "SETTINGS__GOVUK_NOTIFY__API_KEY"
      value = "/${var.environment}/smoketests/notify/api-key"
      type  = "PARAMETER_STORE"
    }

    environment_variable {
      name  = "FORMS_ADMIN_URL"
      value = var.forms_admin_url
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec/buildspec.yml")
  }
}
