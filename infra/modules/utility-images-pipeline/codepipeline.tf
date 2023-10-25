module "artifact_bucket" {
  source = "../secure-bucket"
  name   = "pipeline-utility-images"
}

resource "aws_codepipeline" "main" {
  #checkov:skip=CKV_AWS_219:Amazon Managed SSE is sufficient.
  name     = "utility-images"
  role_arn = aws_iam_role.this.arn

  artifact_store {
    type     = "S3"
    location = module.artifact_bucket.name
  }

  stage {
    name = "Source"
    action {
      name             = "get-forms-deploy"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["forms_deploy"]

      configuration = {
        ConnectionArn    = var.github_connection_arn
        FullRepositoryId = "alphagov/forms-deploy"
        BranchName       = var.forms_deploy_branch
        DetectChanges    = false
      }
    }
  }

  stage {
    name = "Build-docker-images"

    action {
      name            = "Build-end-to-end-test-image"
      namespace       = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["forms_deploy"]
      configuration = {
        ProjectName = module.docker_build_end_to_end_tests.name
      }
    }
  }
}

module "docker_build_end_to_end_tests" {
  source                         = "../code-build-docker-build"
  project_name                   = "docker-build-end-to-end-tests"
  project_description            = "Build the image used to run the end to end tests"
  image_name                     = "end-to-end-tests"
  image_tag                      = "latest"
  docker_username_parameter_path = "/development/dockerhub/username"
  docker_password_parameter_path = "/development/dockerhub/password"
  artifact_store_arn             = module.artifact_bucket.arn
  build_directory                = "infra/modules/code-build-run-smoke-tests/dockerfile"

  # The end-to-end image installs Chrome for x86 so use the following when building it.
  code_build_project_image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  code_build_project_compute_size = "BUILD_GENERAL1_SMALL"
  code_build_project_compute_arch = "LINUX_CONTAINER"
}
