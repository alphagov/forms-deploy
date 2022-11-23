data "aws_caller_identity" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

resource "aws_codebuild_project" "main" {
  name         = var.project_name
  description  = var.project_description
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-aarch64-standard:2.0"
    type            = "ARM_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "BUILD_DIRECTORY"
      value = var.build_directory
    }

    # NOTE: IMAGE_TAG is set via an exported pipeline variable from the GIT repo
    # source. See infra/modules/pipeline/codepipeline.tf:56
    environment_variable {
      name  = "IMAGE_NAME"
      value = var.image_name
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = local.aws_account_id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec/buildspec.yml")
  }

}
