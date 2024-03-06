##
# CodePipeline
##
resource "aws_codepipeline" "deploy-pipeline-visualiser" {
  #checkov:skip=CKV_AWS_219:Amazon Managed SSE is sufficient.

  name          = "deploy-pipeline-visualiser"
  role_arn      = aws_iam_role.pipeline_visualiser_deployer.arn
  pipeline_type = "V2"

  artifact_store {
    type     = "S3"
    location = module.pipeline_visualiser_artifact_bucket.name
  }

  stage {
    name = "Source"

    action {
      name             = "get-forms-deploy"
      namespace        = "get-forms-deploy"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["forms_deploy"]

      configuration = {
        ConnectionArn        = "arn:aws:codestar-connections:eu-west-2:711966560482:connection/8ad08da2-743c-4431-bee6-ad1ae9efebe7"
        FullRepositoryId     = "alphagov/forms-deploy"
        BranchName           = var.pipeline_source_branch
        DetectChanges        = true
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }
  }

  stage {
    name = "Build-Container"

    action {
      name            = "Build"
      namespace       = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["forms_deploy"]
      configuration = {
        ProjectName          = module.pipeline_visualiser_docker_build.name
        EnvironmentVariables = jsonencode([{ "name" : "GIT_SHA", "value" : "#{get-forms-deploy.CommitId}", "type" : "PLAINTEXT" }])
      }
    }
  }

  stage {
    name = "Deploy-To-ECS"

    action {
      name             = "generate-image-definitions"
      namespace        = "generate-image-definitions"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["forms_deploy"]
      output_artifacts = ["image-defs-json"]
      configuration = {
        ProjectName = module.pipeline_visualiser_generate_container_image_defs.name
        EnvironmentVariables = jsonencode([
          {
            name  = "IMAGE_URI"
            value = "711966560482.dkr.ecr.eu-west-2.amazonaws.com/pipeline-visualiser:#{Build.IMAGE_TAG}"
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
        ClusterName       = aws_ecs_cluster.tools.name
        ServiceName       = aws_ecs_service.pipeline_visualiser_service.name
        DeploymentTimeout = 15
        FileName          = "image-defs.json"
      }
    }
  }
}

##
# Code Build
##

module "pipeline_visualiser_docker_build" {
  source                         = "../../../modules/code-build-docker-build"
  project_name                   = "pipeline-visualiser-docker-build"
  project_description            = "Build the Pipleine Visualiser docker image and push into ECR"
  image_name                     = "pipeline-visualiser"
  build_directory                = "support/pipeline-visualiser/"
  docker_username_parameter_path = "/development/dockerhub/username"
  docker_password_parameter_path = "/development/dockerhub/password"
  artifact_store_arn             = module.pipeline_visualiser_artifact_bucket.arn
}

module "pipeline_visualiser_generate_container_image_defs" {
  source              = "../../../modules/code-build-build"
  project_name        = "generate_pipeline_visualiser_container_image_defs"
  project_description = "Generate container image definitions for pipeline-visualiser"
  environment_variables = {
    "TASK_DEFINITION_NAME" = aws_ecs_task_definition.pipeline_visualiser_task.family
  }
  environment                = "deploy"
  artifact_store_arn         = module.pipeline_visualiser_artifact_bucket.arn
  buildspec                  = file("${path.root}/buildspecs/pipeline-visualiser/generate-container-image-definitions.yml")
  log_group_name             = "codebuild/generate_pipeline_visualiser_container_image_defs"
  codebuild_service_role_arn = aws_iam_role.pipeline_visualiser_deployer.arn
}

##
# IAM
##
resource "aws_iam_role" "pipeline_visualiser_deployer" {
  name = "pipeline-visualiser-deployer"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["codepipeline.amazonaws.com", "codebuild.amazonaws.com"]
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "pipeline_visualiser_deployer_policy" {
  role   = aws_iam_role.pipeline_visualiser_deployer.name
  policy = data.aws_iam_policy_document.pipeline_visualiser_deployer.json
}

data "aws_iam_policy_document" "pipeline_visualiser_deployer" {
  statement {
    actions   = ["cloudwatch:*", "logs:*"]
    resources = ["arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:codebuild/*"]
    effect    = "Allow"
  }

  statement {
    actions = ["codebuild:*"]
    resources = [
      module.pipeline_visualiser_docker_build.arn,
      module.pipeline_visualiser_generate_container_image_defs.arn,
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "codestar-connections:UseConnection",
      "codestar-connections:GetConnection",
      "codestar-connections:ListConnections"
    ]
    resources = ["arn:aws:codestar-connections:eu-west-2:711966560482:connection/8ad08da2-743c-4431-bee6-ad1ae9efebe7"]
    effect    = "Allow"
  }
  statement {
    actions   = ["codecommit:Get*", "codecommit:Describe*", "codecommit:GitPull"]
    resources = ["arn:aws:codestar-connections:eu-west-2:711966560482:connection/8ad08da2-743c-4431-bee6-ad1ae9efebe7"]
    effect    = "Allow"
  }

  statement {
    actions   = ["s3:*"]
    resources = ["${module.pipeline_visualiser_artifact_bucket.arn}/*"]
    effect    = "Allow"
  }

  statement {
    actions = ["ecs:*"]
    effect  = "Allow"
    resources = [
      aws_ecs_cluster.tools.arn,
      "arn:aws:ecs:eu-west-2:${data.aws_caller_identity.current.account_id}:service/${aws_ecs_cluster.tools.name}/${aws_ecs_service.pipeline_visualiser_service.name}",
      aws_ecs_task_definition.pipeline_visualiser_task.arn_without_revision,
      "${aws_ecs_task_definition.pipeline_visualiser_task.arn_without_revision}:*"
    ]
  }

  statement {
    actions   = ["ecs:DescribeTaskDefinition"]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = [
      "iam:PassRole",
      "iam:DescribeRole",
      "iam:GetRole"
    ]
    effect = "Allow"
    resources = [
      aws_iam_role.pipeline_visualiser_task.arn,
      aws_iam_role.ecs_task_exec_role.arn
    ]
  }
}
##
# S3
##
module "pipeline_visualiser_artifact_bucket" {
  source = "../../../modules/secure-bucket"
  name   = "pipeline-pipeline-visualiser-artifacts"
}
