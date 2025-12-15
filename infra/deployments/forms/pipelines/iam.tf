data "aws_caller_identity" "current" {}

data "aws_iam_role" "deployer_role" {
  name = "deployer-${var.environment_name}"
}

resource "aws_iam_role" "eventbridge_actor" {
  name               = "event-bridge-actor"
  assume_role_policy = <<-JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
  JSON
}

data "aws_iam_policy_document" "allow_pipeline_start_execution" {
  statement {
    effect    = "Allow"
    actions   = ["codepipeline:StartPipelineExecution"]
    resources = ["arn:aws:codepipeline:eu-west-2:${data.aws_caller_identity.current.account_id}:*"]
  }
}

resource "aws_iam_role_policy" "allow_actor_to_invoke_pipelines" {
  name   = "allow-actor-to-invoke-pipelines"
  role   = aws_iam_role.eventbridge_actor.name
  policy = data.aws_iam_policy_document.allow_pipeline_start_execution.json
}

data "aws_iam_policy_document" "allow_sending_events_to_deploy" {
  statement {
    sid    = "AllowEventsToDeploy"
    effect = "Allow"
    actions = [
      "events:PutEvents"
    ]
    resources = ["arn:aws:events:eu-west-2:${var.deploy_account_id}:event-bus/default"]
  }
}

resource "aws_iam_role_policy" "allow_actor_to_send_events_to_deploy" {
  name   = "allow-actor-to-send-events-to-deploy"
  role   = aws_iam_role.eventbridge_actor.name
  policy = data.aws_iam_policy_document.allow_sending_events_to_deploy.json
}

data "aws_iam_policy_document" "allow_use_of_codebuild_cache_bucket" {
  statement {
    sid    = "AllowUseOfCodeBuildCacheBucket"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = ["arn:aws:s3:::${module.provider_cache_bucket.name}/*"]
  }
}

resource "aws_iam_role_policy" "allow_actor_to_use_codebuild_cache_bucket" {
  name   = "allow-actor-to-use-codebuild-cache-bucket"
  role   = data.aws_iam_role.deployer_role.name
  policy = data.aws_iam_policy_document.allow_use_of_codebuild_cache_bucket.json
}
