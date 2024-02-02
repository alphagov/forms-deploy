data "aws_caller_identity" "current" {}

data "aws_iam_role" "deployer-role" {
  name = "deployer-${var.environment_name}"
}

resource "aws_iam_role" "eventbridge_pipeline_invoker" {
  name               = "event-bridge-pipeline-invoker"
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
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "allow_actor_to_invoke_pipelines" {
  name   = "allow-actor-to-invoke-pipelines"
  role   = aws_iam_role.eventbridge_pipeline_invoker.name
  policy = data.aws_iam_policy_document.allow_pipeline_start_execution.json
}