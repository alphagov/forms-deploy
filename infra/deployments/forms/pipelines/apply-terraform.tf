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

resource "aws_cloudwatch_event_rule" "apply_terraform_on_previous_stage" {
  count = var.apply-terraform.pipeline_trigger == "EVENT" ? 1 : 0

  name        = "apply-terraform-${var.environment_name}-on-previous-stage-success"
  description = "Trigger the apply terraform pipeline for ${var.environment_name} when its previous stage completes"
  role_arn    = aws_iam_role.eventbridge_actor.arn
  event_pattern = jsonencode({
    source = ["aws.codepipeline"],
    detail = {
      state    = ["SUCCEEDED"],
      pipeline = [var.apply-terraform.previous_stage_name]
    }
  })
}

resource "aws_cloudwatch_event_target" "trigger_apply_terraform_pipeline" {
  count = var.apply-terraform.pipeline_trigger == "EVENT" ? 1 : 0

  target_id = "apply-terraform-${var.environment_name}-trigger-deploy-pipeline"
  rule      = aws_cloudwatch_event_rule.apply_terraform_on_previous_stage[0].name
  role_arn  = aws_iam_role.eventbridge_actor.arn
  arn       = aws_codepipeline.apply_terroform.arn
}

resource "aws_codepipeline" "apply_terroform" {
  #checkov:skip=CKV_AWS_219:Amazon Managed SSE is sufficient.
  name           = "apply-forms-terraform-${var.environment_name}"
  role_arn       = data.aws_iam_role.deployer-role.arn
  pipeline_type  = "V2"

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
        BranchName           = var.apply-terraform.pipeline_trigger == "GIT" ? var.apply-terraform.git_source_branch : "main"
        DetectChanges        = var.apply-terraform.pipeline_trigger == "GIT"
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