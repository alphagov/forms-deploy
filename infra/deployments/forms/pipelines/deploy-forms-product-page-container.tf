## Triggers
resource "aws_cloudwatch_event_rule" "product_pages_on_image_tag" {
  name        = "product-page-on-${var.environment_name}-image-tag"
  description = "Trigger the product pages pipeline when a new container image tag matching the desired pattern is pushed"
  role_arn    = aws_iam_role.eventbridge_pipeline_invoker.arn
  event_pattern = jsonencode({
    source = ["aws.ecr", "uk.gov.service.forms"]
    detail = {
      action-type = ["PUSH"]
      image-tag = [
        { wildcard = var.deploy-forms-product-page-container.trigger_on_tag_pattern }
      ]
      repository-name = ["forms-product-page-deploy"]
    }
  })
}

resource "aws_cloudwatch_event_target" "trigger_product_page_pipeline" {
  target_id = "product-page-${var.environment_name}-trigger-deploy-pipeline"
  rule      = aws_cloudwatch_event_rule.product_pages_on_image_tag.name
  role_arn  = aws_iam_role.eventbridge_pipeline_invoker.arn
  arn       = aws_codepipeline.deploy_product_pages_container.arn

  input_transformer {
    input_paths = {
      image-tag  = "$.detail.image-tag"
      repository = "$.detail.repository-name"
    }

    input_template = <<EOF
{
  "name": "${aws_codepipeline.deploy_product_pages_container.name}",
  "variables": [
    {
      "name": "container_image_uri",
      "value": "711966560482.dkr.ecr.eu-west-2.amazonaws.com/forms-product-page-deploy:<image-tag>"
    }
  ]
}
EOF
  }

  depends_on = [
    aws_codepipeline.deploy_product_pages_container
  ]
}

## Pipeline
data "archive_file" "deploy_product_pages_buildpsec_zip" {
  type        = "zip"
  output_path = "${path.root}/zip-files/deploy_product_pages_buildpsec_zip.zip"

  source {
    content  = file("${path.root}/buiidspecs/generate-container-image-defs/generate-container-image-defs.yml")
    filename = "/codebuild/readonly/buildspec.yml"
  }
}
resource "aws_s3_object" "deploy_product_pages_container_trigger_key" {
  depends_on = [data.archive_file.deploy_product_pages_buildpsec_zip]

  bucket = module.artifact_bucket.name
  key    = "codepipeline-source-keys/deploy_product_pages"
  source = "${path.root}/zip-files/deploy_product_pages_buildpsec_zip.zip"
}

resource "aws_codepipeline" "deploy_product_pages_container" {
  depends_on = [aws_s3_object.deploy_product_pages_container_trigger_key]

  #checkov:skip=CKV_AWS_219:Amazon Managed SSE is sufficient.
  name          = "deploy-forms-product-page-container-${var.environment_name}"
  role_arn      = data.aws_iam_role.deployer-role.arn
  pipeline_type = "V2"

  artifact_store {
    type     = "S3"
    location = module.artifact_bucket.name
  }

  variable {
    name          = "container_image_uri"
    default_value = "MUST_BE_SET"
    description   = "The URI of the container image which should be deployed"
  }

  stage {
    #
    # This source action is deliberately NOT a Git source.
    #
    # We would like to trigger this pipeline using AWS EventBridge
    # with a container image URI as input, however the ECR action
    # does not support cross-account repositories, and CodePipeline
    # requires that we have a minimum of one source action.
    #
    # The AWS CodeBuild action we use to generate the image definitions
    # also requires at least one input artefact, and that artefact must
    # contain a copy of the buildspec.
    #
    # To satisfy all of these requirements we
    # 1. take the image URI as a variable,
    # 2. create and store a zip file containing the buildspec inside the
    #    artifact bucket, and set that object as the key for the S3 source,
    # 3. prevent changes to that object from ever triggering the pipeline
    #    (PollForSourceChanges = false).
    ##
    name = "Source"
    action {
      name             = "buildspec-source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["buildspec_source"]

      configuration = {
        S3Bucket             = module.artifact_bucket.name
        S3ObjectKey          = "codepipeline-source-keys/deploy_product_pages"
        PollForSourceChanges = false
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
        ConnectionArn        = var.codestar_connection_arn
        FullRepositoryId     = "alphagov/forms-e2e-tests"
        BranchName           = "main" # TODO: we should version this repository appropriately, so we can pick specific versions
        DetectChanges        = false
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }
  }

  stage {
    name = "deploy-to-ecs"

    action {
      name             = "generate-image-definitions"
      namespace        = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["buildspec_source"]
      output_artifacts = ["image-defs-json"]
      configuration = {
        ProjectName = module.generate_forms_product_pages_container_image_defs.name
        EnvironmentVariables = jsonencode([
          {
            name  = "IMAGE_URI"
            value = "#{variables.container_image_uri}"
            type  = "PLAINTEXT"
          }
        ])
      }
    }

    action {
      name            = "deploy-new-task-definition"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      run_order       = 2
      input_artifacts = ["image-defs-json"]
      configuration = {
        ClusterName       = "forms-${var.environment_name}"
        ServiceName       = "forms-product-page"
        DeploymentTimeout = 15
        FileName          = "image-defs.json"
      }
    }
  }

  stage {
    name = "test"

    action {
      name            = "run-end-to-end-tests"
      category        = "Build"
      run_order       = "2"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["forms_e2e_tests"]
      configuration = {
        ProjectName = module.deploy_product_pages_end_to_end_tests.name
      }
    }
  }
}


module "generate_forms_product_pages_container_image_defs" {
  source              = "../../../modules/code-build-build"
  project_name        = "generate_forms_product_pages_container_image_defs_${var.environment_name}"
  project_description = "Generate container image definitions for forms-product-pages"
  environment_variables = {
    "TASK_DEFINITION_NAME" = "${var.environment_name}_forms-product-page"
  }
  environment                = var.environment_name
  artifact_store_arn         = module.artifact_bucket.arn
  buildspec                  = file("${path.root}/buiidspecs/generate-container-image-defs/generate-container-image-defs.yml")
  log_group_name             = "codebuild/generate_forms_product_pages_container_image_defs_${var.environment_name}"
  codebuild_service_role_arn = data.aws_iam_role.deployer-role.arn
}

module "deploy_product_pages_end_to_end_tests" {
  source             = "../../../modules/code-build-run-smoke-tests"
  app_name           = "forms-product-page"
  environment        = var.environment_name
  forms_admin_url    = "https://admin.${var.root_domain}"
  product_pages_url  = "https://${var.root_domain}"
  artifact_store_arn = module.artifact_bucket.arn
}