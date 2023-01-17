resource "aws_codepipeline" "main" {
  #checkov:skip=CKV_AWS_219:Amazon Managed SSE is sufficient.
  name     = var.app_name
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
      name            = "run-smoke-tests-staging"
      category        = "Build"
      run_order       = "2"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["forms_deploy"]
      configuration = {
        ProjectName = module.smoke_tests_staging.name
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
      name            = "run-smoke-tests-production"
      category        = "Build"
      run_order       = "2"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["forms_deploy"]
      configuration = {
        ProjectName = module.smoke_tests_production.name
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
      name            = "run-smoke-tests-dev"
      category        = "Build"
      owner           = "AWS"
      run_order       = "2"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["forms_deploy"]
      configuration = {
        ProjectName = module.smoke_tests_dev.name
      }
    }
  }
}

module "docker_build" {
  source                         = "../code-build-docker-build"
  project_name                   = "docker-build-${var.app_name}"
  project_description            = "Build the forms-api docker image and push into ECR"
  image_name                     = "${var.app_name}-deploy"
  docker_username_parameter_path = "/development/dockerhub/username"
  docker_password_parameter_path = "/development/dockerhub/password"
  artifact_store_arn             = aws_s3_bucket.codepipeline.arn
}

module "terraform_apply_staging" {
  source             = "../code-build-deploy-ecs"
  app_name           = var.app_name
  environment        = "staging"
  artifact_store_arn = aws_s3_bucket.codepipeline.arn
}

module "smoke_tests_staging" {
  source                         = "../code-build-run-smoke-tests"
  project_name                   = "${var.app_name}-smoke-tests-staging"
  project_description            = "Run smoke tests for ${var.app_name} in staging"
  signon_username_parameter_path = "/staging/smoketests/signon/username"
  signon_password_parameter_path = "/staging/smoketests/signon/password"
  signon_secret_parameter_path   = "/staging/smoketests/signon/secret"
  forms_admin_url                = "https://admin.stage.forms.service.gov.uk"
  artifact_store_arn             = aws_s3_bucket.codepipeline.arn

  notify_api_key_secret_parameter_path = "/staging/smoketests/notify/api-key"
}

module "terraform_apply_production" {
  source             = "../code-build-deploy-ecs"
  app_name           = var.app_name
  environment        = "production"
  artifact_store_arn = aws_s3_bucket.codepipeline.arn
}

module "smoke_tests_production" {
  source                         = "../code-build-run-smoke-tests"
  project_name                   = "${var.app_name}-smoke-tests-production"
  project_description            = "Run smoke tests for ${var.app_name} in production"
  signon_username_parameter_path = "/production/smoketests/signon/username"
  signon_password_parameter_path = "/production/smoketests/signon/password"
  signon_secret_parameter_path   = "/production/smoketests/signon/secret"
  forms_admin_url                = "https://admin.prod-temp.forms.service.gov.uk" #TODO: Update for migration
  artifact_store_arn             = aws_s3_bucket.codepipeline.arn

  notify_api_key_secret_parameter_path = "/production/smoketests/notify/api-key"
}

module "terraform_apply_dev" {
  source             = "../code-build-deploy-ecs"
  app_name           = var.app_name
  environment        = "dev"
  artifact_store_arn = aws_s3_bucket.codepipeline.arn
}

module "smoke_tests_dev" {
  source                         = "../code-build-run-smoke-tests"
  project_name                   = "${var.app_name}-smoke-tests-dev"
  project_description            = "Run smoke tests for ${var.app_name} in dev"
  signon_username_parameter_path = "/development/smoketests/signon/username"
  signon_password_parameter_path = "/development/smoketests/signon/password"
  signon_secret_parameter_path   = "/development/smoketests/signon/secret"
  forms_admin_url                = "https://admin.dev.forms.service.gov.uk"
  artifact_store_arn             = aws_s3_bucket.codepipeline.arn

  notify_api_key_secret_parameter_path = "/development/smoketests/notify/api-key"
}
