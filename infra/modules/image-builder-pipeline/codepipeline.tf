
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
            name             = "get-${var.application_name}"
            namespace        = "get-${var.application_name}"
            category         = "Source"
            owner            = "AWS"
            provider         = "CodeStarSourceConnection"
            version          = "1"
            output_artifacts = ["source_repo"]

            configuration = {
                ConnectionArn        = var.github_connection_arn
                FullRepositoryId     = var.source_repository
                BranchName           = "main"
                OutputArtifactFormat = "CODEBUILD_CLONE_REF"
                DetectChanges        = true
            }
        }
    }

    stage {
        name = "Build-docker-image"

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
                EnvironmentVariables = jsonencode([{ "name" : "GIT_SHA", "value" : "#{get-${var.application_name}.CommitId}", "type" : "PLAINTEXT" }])
            }
        }
    }
}

module "docker_build" {
    source                         = "../code-build-docker-build"
    project_name                   = "${var.application_name}-docker-build"
    project_description            = "Build the ${var.application_name} docker image from a development branch and push into ECR"
    image_name                     = "${var.application_name}-deploy"
    docker_username_parameter_path = "/development/dockerhub/username"
    docker_password_parameter_path = "/development/dockerhub/password"
    artifact_store_arn             = module.artifact_bucket.arn
    tag_prefix                     = "stg-"
}