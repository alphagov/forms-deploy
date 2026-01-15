data "aws_caller_identity" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  project_name   = "scheduled-${var.test_name}-${var.environment}"
}

resource "aws_codebuild_project" "run_test" {
  #checkov:skip=CKV_AWS_147:Amazon Managed SSE is sufficient.
  name         = "${var.environment}-${var.test_name}"
  description  = "Run ${var.test_name} in ${var.environment}"
  service_role = aws_iam_role.codebuild.arn

  build_timeout = 5

  source {
    type      = "NO_SOURCE"
    buildspec = file("${path.module}/buildspec/buildspec.yml")
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.log_group.name
      stream_name = "smoke_tests"
    }
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "${var.container_registry}/end-to-end-tests:latest"
    type         = "LINUX_CONTAINER"

    image_pull_credentials_type = "SERVICE_ROLE"

    dynamic "environment_variable" {
      for_each = var.codebuild_environment_variables

      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }

    environment_variable {
      name  = "SETTINGS__FORMS_ENV"
      value = var.environment
    }

    environment_variable {
      name  = "RSPEC_PATH"
      value = var.rspec_path
    }

    environment_variable {
      name  = "LOG_LEVEL"
      value = "INFO"
    }
  }
}
