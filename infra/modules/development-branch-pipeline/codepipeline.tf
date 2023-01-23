locals {
  name_suffix = "${var.app_name}-${var.environment}-dev-branches"
}

module "artifact_bucket" {
  source = "../secure-bucket"
  name   = "pipeline-${local.name_suffix}"
}

resource "aws_codepipeline" "main" {
  #checkov:skip=CKV_AWS_219:Amazon Managed SSE is sufficient.
  name     = local.name_suffix
  role_arn = aws_iam_role.codepipeline.arn

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

    action {
      name             = "get-${var.app_name}"
      namespace        = "get-${var.app_name}"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_repo"]

      configuration = {
        ConnectionArn    = var.github_connection_arn
        FullRepositoryId = "alphagov/${var.app_name}"
        BranchName       = var.source_branch
      }
    }
  }

  stage {
    name = "Build-${var.app_name}-docker-image"

    action {
      name            = "Build"
      namespace       = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_repo"]
      configuration = {
        ProjectName          = module.docker_build.name
        EnvironmentVariables = jsonencode([{ "name" : "GIT_SHA", "value" : "#{get-${var.app_name}.CommitId}", "type" : "PLAINTEXT" }])
      }
    }
  }

  stage {
    name = "Deploy-to-${var.environment}-environment"

    action {
      name            = "terraform-apply"
      category        = "Build"
      run_order       = "1"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["forms_deploy"]
      configuration = {
        ProjectName          = module.terraform_apply.name
        EnvironmentVariables = jsonencode([{ "name" : "IMAGE_TAG", "value" : "#{Build.IMAGE_TAG}", "type" : "PLAINTEXT" }])
      }
    }
  }
}

module "docker_build" {
  source                         = "../code-build-docker-build"
  project_name                   = "${var.app_name}-docker-build-${var.environment}-dev-branches"
  project_description            = "Build the forms-api docker image and push into ECR"
  image_name                     = "${var.app_name}-deploy"
  docker_username_parameter_path = "/development/dockerhub/username"
  docker_password_parameter_path = "/development/dockerhub/password"
  artifact_store_arn             = module.artifact_bucket.arn
  tag_prefix                     = "development-branch-"
}

module "terraform_apply" {
  source              = "../code-build-deploy-ecs"
  app_name            = var.app_name
  project_name_suffix = "-dev-branches"
  environment         = var.environment
  artifact_store_arn  = module.artifact_bucket.arn
}
