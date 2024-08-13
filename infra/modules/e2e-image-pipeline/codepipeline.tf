module "artifact_bucket" {
  source = "../secure-bucket"
  name   = "pipeline-e2e-image"
}

resource "aws_codepipeline" "main" {
  #checkov:skip=CKV_AWS_219:Amazon Managed SSE is sufficient.
  name           = "e2e-image"
  role_arn       = aws_iam_role.this.arn
  pipeline_type  = "V2"
  execution_mode = "QUEUED"

  artifact_store {
    type     = "S3"
    location = module.artifact_bucket.name
  }

  stage {
    name = "Source"
    action {
      name             = "get-forms-e2e-tests"
      namespace        = "get-forms-e2e-tests"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["forms_e2e_tests"]

      configuration = {
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = "alphagov/forms-e2e-tests"
        BranchName       = var.forms_e2e_tests_branch
        DetectChanges    = true
      }
    }
  }

  stage {
    name = "Build-test-and-push"

    action {
      name            = "Build"
      namespace       = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["forms_e2e_tests"]
      configuration = {
        ProjectName          = module.docker_build.name
        EnvironmentVariables = jsonencode([{ "name" : "GIT_SHA", "value" : "#{get-forms-e2e-tests.CommitId}", "type" : "PLAINTEXT" }])
      }
    }
  }
}

module "docker_build" {
  source                         = "../code-build-docker-build"
  project_name                   = "docker-build-e2e-tests"
  project_description            = "Build the image used to run the end to end tests"
  image_name                     = "end-to-end-tests"
  tag_latest                     = true
  docker_username_parameter_path = "/docker/username"
  docker_password_parameter_path = "/docker/password"
  artifact_store_arn             = module.artifact_bucket.arn
  build_directory                = "."
  codestar_connection_arn        = var.codestar_connection_arn

  # Selenium is not compatible with aarch64.
  code_build_project_compute_arch = "LINUX_CONTAINER"
  code_build_project_image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"

  extra_env_vars = [
    {
      name  = "FORMS_ADMIN_URL"
      value = "https://admin.dev.forms.service.gov.uk"
      type  = "PLAINTEXT"
    },
    {
      name  = "PRODUCT_PAGES_URL"
      value = "https://dev.forms.service.gov.uk"
      type  = "PLAINTEXT"
    },
    {
      name  = "SMOKE_TEST_FORM_URL"
      value = "https://submit.forms.service.gov.uk/form/2570/scheduled-smoke-test"
      type  = "PLAINTEXT"
    },
    {
      name  = "AUTH0_EMAIL_USERNAME"
      value = "/dev/automated-tests/e2e/auth0/email-username"
      type  = "PARAMETER_STORE"
    },
    {
      name  = "AUTH0_USER_PASSWORD"
      value = "/dev/automated-tests/e2e/auth0/auth0-user-password"
      type  = "PARAMETER_STORE"
    },
    {
      name  = "SETTINGS__GOVUK_NOTIFY__API_KEY"
      value = "/dev/automated-tests/e2e/notify/api-key"
      type  = "PARAMETER_STORE"
    },
  ]
}
