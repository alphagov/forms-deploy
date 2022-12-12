data "aws_caller_identity" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

resource "aws_codebuild_project" "smoke_tests" {
  name         = var.project_name
  description  = var.project_description
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
      value = var.signon_username_parameter_path
      type  = "PARAMETER_STORE"
    }

    environment_variable {
      name  = "SIGNON_PASSWORD"
      value = var.signon_password_parameter_path
      type  = "PARAMETER_STORE"
    }

    environment_variable {
      name  = "SIGNON_OTP"
      value = var.signon_secret_parameter_path
      type  = "PARAMETER_STORE"
    }

    environment_variable {
      name  = "SETTINGS__GOVUK_NOTIFY__API_KEY"
      value = var.notify_api_key_secret_parameter_path
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
