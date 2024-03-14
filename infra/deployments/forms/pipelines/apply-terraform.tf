locals {
  roots = toset([
    "alerts",
    "auth0",
    "dns",
    "environment",
    "forms-product-page",
    "forms-runner",
    "monitoring",
    "pipelines",
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
    source      = ["uk.gov.service.forms"],
    detail-type = ["Terraform application succesful"]
    detail = {
      environment = [var.apply-terraform.previous_stage_name]
    }
  })
}

resource "aws_cloudwatch_event_target" "trigger_apply_terraform_pipeline" {
  count = var.apply-terraform.pipeline_trigger == "EVENT" ? 1 : 0

  target_id = "apply-terraform-${var.environment_name}-trigger-deploy-pipeline"
  rule      = aws_cloudwatch_event_rule.apply_terraform_on_previous_stage[0].name
  arn       = aws_lambda_function.pipeline_invoker.arn

  input_transformer {
    input_paths = {
      source-commit = "$.detail.source-commit"
    }

    input_template = <<EOF
    {
      "name": "${aws_codepipeline.apply_terroform.name}",
      "sourceRevisions": [
        {
          "actionName": "get-forms-deploy",
          "revisionType": "COMMIT_ID",
          "revisionValue": "<source-commit>"
        }
      ]
    }
    EOF
  }

  dead_letter_config {
    arn = aws_sqs_queue.event_bridge_dlq.arn
  }
}

resource "aws_codepipeline" "apply_terroform" {
  #checkov:skip=CKV_AWS_219:Amazon Managed SSE is sufficient.
  name          = "apply-forms-terraform-${var.environment_name}"
  role_arn      = data.aws_iam_role.deployer-role.arn
  pipeline_type = "V2"

  artifact_store {
    type     = "S3"
    location = module.artifact_bucket.name
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
        ConnectionArn        = var.codestar_connection_arn
        FullRepositoryId     = "alphagov/forms-deploy"
        BranchName           = var.apply-terraform.pipeline_trigger == "GIT" ? var.apply-terraform.git_source_branch : "main"
        DetectChanges        = var.apply-terraform.pipeline_trigger == "GIT"
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }
  }

  stage {
    name = "self-update-pipelines"

    action {
      name            = "self-update-pipelines"
      category        = "Build"
      run_order       = "1"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["forms_deploy"]
      configuration = {
        ProjectName = module.terraform_apply["pipelines"].name
      }
    }
  }

  stage {
    name = "terraform-apply"

    dynamic "action" {
      # don't run pipelines because we did it in the previous stage
      for_each = setsubtract(local.roots, ["pipelines"])

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

  stage {
    name = "publish-completion-event"

    action {
      name            = "publish-completion-event"
      category        = "Build"
      run_order       = "1"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["forms_deploy"]

      configuration = {
        ProjectName = module.publish_complete_event.name
        EnvironmentVariables = jsonencode([
          {
            name  = "COMMIT_ID"
            value = "#{get-forms-deploy.CommitId}"
            type  = "PLAINTEXT "
          },
          {
            name  = "ENV_NAME"
            value = var.environment_name
            type  = "PLAINTEXT"
          },
          {
            name  = "TARGET_EVENT_BUS"
            value = "arn:aws:events:eu-west-2:711966560482:event-bus/default"
            type  = "PLAINTEXT"
          }
        ])
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

module "publish_complete_event" {
  source                     = "../../../modules/code-build-build"
  project_name               = "${var.environment_name}-deploy-terraform-completed"
  project_description        = "Publush event to mark terraform application complete"
  environment                = var.environment_name
  artifact_store_arn         = module.artifact_bucket.arn
  buildspec                  = file("${path.root}/buiidspecs/apply-terraform/terraform-application-successful-event.yml")
  log_group_name             = "codebuild/deploy-terraform-${var.environment_name}-completed"
  codebuild_service_role_arn = data.aws_iam_role.deployer-role.arn
}