data "aws_caller_identity" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

resource "aws_codebuild_project" "main" {
  #checkov:skip=CKV_AWS_147:Amazon Managed SSE is sufficient.
  name         = var.project_name
  description  = var.project_description
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = var.code_build_project_compute_size
    image           = var.code_build_project_image
    type            = var.code_build_project_compute_arch
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
      name  = "TAG_PREFIX"
      value = var.tag_prefix
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = var.image_tag
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = local.aws_account_id
    }

    environment_variable {
      name  = "DOCKER_USERNAME"
      value = var.docker_username_parameter_path
      type  = "PARAMETER_STORE"
    }

    environment_variable {
      name  = "DOCKER_PASSWORD"
      value = var.docker_password_parameter_path
      type  = "PARAMETER_STORE"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec/buildspec.yml")
  }
}
