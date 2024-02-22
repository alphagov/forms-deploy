data "aws_caller_identity" "current" {}

locals {
  deploy_account_id = "711966560482"
  aws_account_id    = data.aws_caller_identity.current.account_id
  project_name      = "scheduled-smoke-tests-${var.environment}"
}

resource "aws_codebuild_project" "smoke_tests" {
  #checkov:skip=CKV_AWS_147:Amazon Managed SSE is sufficient.
  name         = local.project_name
  description  = "Run scheduled smoke tests in ${var.environment}"
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
    image        = "711966560482.dkr.ecr.eu-west-2.amazonaws.com/end-to-end-tests:smoke-test-spike"
    type         = "LINUX_CONTAINER"

    image_pull_credentials_type = "SERVICE_ROLE"

    environment_variable {
      name  = "SMOKE_TEST_FORM_URL"
      value = var.smoke_test_form_url
    }

    environment_variable {
      name  = "LOG_LEVEL"
      value = "INFO"
    }
  }
}
