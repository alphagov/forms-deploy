module "artifact_bucket" {
  source = "../secure-bucket"
  name   = "pipeline-${var.app_name}-main-branch"
}

resource "aws_codepipeline" "main" {
  #checkov:skip=CKV_AWS_219:Amazon Managed SSE is sufficient.
  name     = "${var.app_name}-main-branch"
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
        ConnectionArn        = var.github_connection_arn
        FullRepositoryId     = "alphagov/forms-deploy"
        BranchName           = var.forms_deploy_branch
        DetectChanges        = false
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
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
        ConnectionArn        = var.github_connection_arn
        FullRepositoryId     = "alphagov/${var.app_name}"
        BranchName           = var.source_branch
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }

    action {
      name             = "get-forms-e2e-tests"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["forms_e2e_tests"]

      configuration = {
        ConnectionArn        = var.github_connection_arn
        FullRepositoryId     = "alphagov/forms-e2e-tests"
        BranchName           = var.forms_e2e_tests_branch
        DetectChanges        = false
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
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
    name = "Deploy-to-staging-environment"

    action {
      name            = "terraform-apply"
      category        = "Build"
      run_order       = "1"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["forms_deploy"]
      configuration = {
        ProjectName          = module.terraform_apply_staging.name
        EnvironmentVariables = jsonencode([{ "name" : "IMAGE_TAG", "value" : "#{Build.IMAGE_TAG}", "type" : "PLAINTEXT" }])
      }
    }

    action {
      name            = "run-e2e-tests-staging"
      category        = "Build"
      run_order       = "2"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["forms_e2e_tests"]
      configuration = {
        ProjectName = module.e2e_tests_staging.name
      }
    }
  }

  stage {
    name = "Deploy-to-production-environment"

    action {
      name            = "terraform-apply"
      category        = "Build"
      run_order       = "1"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["forms_deploy"]
      configuration = {
        ProjectName          = module.terraform_apply_production.name
        EnvironmentVariables = jsonencode([{ "name" : "IMAGE_TAG", "value" : "#{Build.IMAGE_TAG}", "type" : "PLAINTEXT" }])
      }
    }

    action {
      name            = "run-e2e-tests-production"
      category        = "Build"
      run_order       = "2"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["forms_e2e_tests"]
      configuration = {
        ProjectName = module.e2e_tests_production.name
      }
    }
  }

  stage {
    name = "Deploy-to-dev-environment"

    action {
      name            = "terraform-apply"
      category        = "Build"
      run_order       = "1"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["forms_deploy"]
      configuration = {
        ProjectName          = module.terraform_apply_dev.name
        EnvironmentVariables = jsonencode([{ "name" : "IMAGE_TAG", "value" : "#{Build.IMAGE_TAG}", "type" : "PLAINTEXT" }])
      }
    }

    action {
      name            = "run-e2e-tests-dev"
      category        = "Build"
      owner           = "AWS"
      run_order       = "2"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["forms_e2e_tests"]
      configuration = {
        ProjectName = module.e2e_tests_dev.name
      }
    }
  }

  stage {
    name = "Deploy-to-user-research-environment"

    action {
      name            = "terraform-apply"
      category        = "Build"
      run_order       = "1"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["forms_deploy"]
      configuration = {
        ProjectName          = module.terraform_apply_user_research.name
        EnvironmentVariables = jsonencode([{ "name" : "IMAGE_TAG", "value" : "#{Build.IMAGE_TAG}", "type" : "PLAINTEXT" }])
      }
    }
  }
}

module "docker_build" {
  source                         = "../code-build-docker-build"
  project_name                   = "${var.app_name}-docker-build-main-branch"
  project_description            = "Build the ${var.app_name} docker image from main branch and push into ECR"
  image_name                     = "${var.app_name}-deploy"
  docker_username_parameter_path = "/development/dockerhub/username"
  docker_password_parameter_path = "/development/dockerhub/password"
  artifact_store_arn             = module.artifact_bucket.arn
}

module "terraform_apply_staging" {
  source             = "../code-build-deploy-ecs"
  app_name           = var.app_name
  environment        = "staging"
  artifact_store_arn = module.artifact_bucket.arn
}

module "e2e_tests_staging" {
  source             = "../code-build-run-e2e-tests"
  app_name           = var.app_name
  environment_name   = "staging"
  forms_admin_url    = "https://admin.staging.forms.service.gov.uk"
  product_pages_url  = "https://staging.forms.service.gov.uk"
  artifact_store_arn = module.artifact_bucket.arn

  auth0_user_name_parameter_name     = "/staging/automated-tests/e2e/auth0/email-username"
  auth0_user_password_parameter_name = "/staging/automated-tests/e2e/auth0/auth0-user-password"
  notify_api_key_parameter_name      = "/staging/automated-tests/e2e/notify/api-key"
}

module "terraform_apply_production" {
  source             = "../code-build-deploy-ecs"
  app_name           = var.app_name
  environment        = "production"
  artifact_store_arn = module.artifact_bucket.arn
}

module "e2e_tests_production" {
  source             = "../code-build-run-e2e-tests"
  app_name           = var.app_name
  environment_name   = "production"
  forms_admin_url    = "https://admin.forms.service.gov.uk"
  product_pages_url  = "https://forms.service.gov.uk"
  artifact_store_arn = module.artifact_bucket.arn

  auth0_user_name_parameter_name     = "/production/automated-tests/e2e/auth0/email-username"
  auth0_user_password_parameter_name = "/production/automated-tests/e2e/auth0/auth0-user-password"
  notify_api_key_parameter_name      = "/production/automated-tests/e2e/notify/api-key"
}

module "terraform_apply_dev" {
  source             = "../code-build-deploy-ecs"
  app_name           = var.app_name
  environment        = "dev"
  artifact_store_arn = module.artifact_bucket.arn
}

module "e2e_tests_dev" {
  source             = "../code-build-run-e2e-tests"
  app_name           = var.app_name
  environment_name   = "dev"
  forms_admin_url    = "https://admin.dev.forms.service.gov.uk"
  product_pages_url  = "https://dev.forms.service.gov.uk"
  artifact_store_arn = module.artifact_bucket.arn

  auth0_user_name_parameter_name     = "/dev/automated-tests/e2e/auth0/email-username"
  auth0_user_password_parameter_name = "/dev/automated-tests/e2e/auth0/auth0-user-password"
  notify_api_key_parameter_name      = "/dev/automated-tests/e2e/notify/api-key"
}

module "terraform_apply_user_research" {
  source             = "../code-build-deploy-ecs"
  app_name           = var.app_name
  environment        = "user-research"
  artifact_store_arn = module.artifact_bucket.arn
}

