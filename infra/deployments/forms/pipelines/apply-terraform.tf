locals {
  roots = toset([
    "alerts",
    "auth0",
    "dns",
    "environment",
    "monitoring",
    "rds",
    "redis",
    "ses",
  ])
}

resource "aws_codepipeline" "apply_terroform" {
  #checkov:skip=CKV_AWS_219:Amazon Managed SSE is sufficient.
  name     = "apply-forms-terraform-${var.environment_name}"
  role_arn = data.aws_iam_role.deployer-role.arn

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
        ConnectionArn        = var.codestar_connection_arn
        FullRepositoryId     = "alphagov/forms-deploy"
        BranchName           = "main"
        DetectChanges        = false
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }
  }

  stage {
    name = "terraform-apply"

    dynamic "action" {
      for_each = local.roots

      content {
        name            = "terraform-apply-${action.value}"
        category        = "Build"
        run_order       = "1"
        owner           = "AWS"
        provider        = "CodeBuild"
        version         = "1"
        input_artifacts = ["forms_deploy"]
        configuration = {
          ProjectName = module.terraform_apply[action.value].name
        }
      }
    }
  }
}


module "terraform_apply" {
  # All roots under `infra/deployments/forms/`, excluding the roots which
  # deploy one of the apps. They have their own pipelines.
  for_each            = local.roots
  source              = "../../../modules/code-build-build"
  project_name        = "${each.value}-deploy-${var.environment_name}"
  project_description = "Terraform apply forms/${each.value} in ${var.environment_name}"
  environment_variables = {
    "ROOT_NAME" = each.value
  }
  environment                = var.environment_name
  artifact_store_arn         = module.artifact_bucket.arn
  buildspec                  = file("${path.root}/buiidspecs/apply-terraform/apply-terraform.yml")
  log_group_name             = "codebuild/${each.value}-deploy-${var.environment_name}"
  codebuild_service_role_arn = data.aws_iam_role.deployer-role.arn
}