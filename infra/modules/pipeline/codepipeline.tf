resource "aws_codepipeline" "main" {
  name     = var.terraform_deployment
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.codepipeline.bucket
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
        BranchName       = "code_pipeline"
      }
    }

    action {
      name             = "get-${var.source_repo}"
      namespace        = "get-${var.source_repo}"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_repo"]

      configuration = {
        ConnectionArn    = var.github_connection_arn
        FullRepositoryId = "alphagov/${var.source_repo}"
        BranchName       = var.source_branch
      }
    }
  }

  stage {
    name = "Build-${var.source_repo}-docker-image"

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
        EnvironmentVariables = "[{\"name\":\"GIT_SHA\",\"value\":\"#{get-${var.source_repo}.CommitId}\",\"type\":\"PLAINTEXT\"}]"
      }
    }
  }

  stage {
    name = "Deploy-to-dev-environment"

    action {
      name            = "terraform-apply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["forms_deploy"]
      configuration = {
        ProjectName          = module.terraform_apply_dev.name
        EnvironmentVariables = "[{\"name\":\"IMAGE_TAG\",\"value\":\"#{Build.IMAGE_TAG}\",\"type\":\"PLAINTEXT\"}]"
      }
    }
  }
}

module "docker_build" {
  source              = "../code-build-docker-build"
  project_name        = "docker-build-${var.source_repo}"
  project_description = "Build the forms-api docker image and push into ECR"
  image_name          = var.image_name
  artifact_store_arn  = aws_s3_bucket.codepipeline.arn
}

module "terraform_apply_dev" {
  source              = "../code-build-run-terraform"
  project_name        = "${var.terraform_deployment}-deploy-dev"
  project_description = "Run terraform apply for ${var.terraform_deployment} in dev"
  deployer_role_arn   = var.development_deployer_role_arn
  deploy_directory    = "infra/deployments/development/${var.terraform_deployment}"
  terraform_command   = "apply --auto-approve" # TODO: pass in vars.
  artifact_store_arn  = aws_s3_bucket.codepipeline.arn
}

