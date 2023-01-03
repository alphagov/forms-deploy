resource "aws_codebuild_project" "terraform" {
  #checkov:skip=CKV_AWS_147:Amazon Managed SSE is sufficient.
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
      name  = "DEPLOYER_ROLE_ARN"
      value = var.deployer_role_arn
    }
    environment_variable {
      name  = "DEPLOY_DIRECTORY"
      value = var.deploy_directory
    }
    environment_variable {
      name  = "TERRAFORM_VERSION"
      value = var.terraform_version
    }
    environment_variable {
      name  = "CLUSTER_NAME"
      value = var.cluster_name
    }
    environment_variable {
      name  = "SERVICE_NAME"
      value = var.service_name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec/buildspec.yml")
  }
}
