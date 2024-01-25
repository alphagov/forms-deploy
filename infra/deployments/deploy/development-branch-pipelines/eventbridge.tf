# AWS Cloud Watch Events was renamed Event Bridge

resource "aws_cloudwatch_event_rule" "trigger_rule" {
    name = "on-runner-complete"
    description = "When a deployment to Forms Runner completes"
    
    role_arn = aws_iam_role.eventbridge_actor.arn
    event_bus_name = "default"
    event_pattern = jsonencode({
        source = ["aws.codepipeline"]
        resources = [module.forms-runner-dev-pipeline.pipeline_arn]
        detail = {
            state = ["SUCCEEDED"]
        }
    })
}

resource "aws_cloudwatch_event_target" "target" {
    target_id = "dev-product-pages"

    rule = aws_cloudwatch_event_rule.trigger_rule.name
    arn = module.forms-product-page-dev-pipeline.pipeline_arn
    role_arn = aws_iam_role.eventbridge_actor.arn

    input_transformer {
        input_paths = {
            pipeline = "$.detail.pipeline"
            forms_deploy_commit_id = "$.detail.execution-trigger.commit-id"
        }
        input_template = <<EOF
{
    "name": <pipeline>,
    "sourceRevisions": [
        {
            "actionName": "get-forms-deploy",
            "revisionType": "COMMIT_ID",
            "revisionValue": <forms_deploy_commit_id>
        }
    ]
}
EOF
    }
}

resource "aws_iam_role" "eventbridge_actor" {
    name = "ah-event-bridge-action"
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

resource "aws_iam_role_policy" "allow_triggering_codepipeline" {
    name = "allow_triggering_codepipeline"
    role = aws_iam_role.eventbridge_actor.id
    policy = data.aws_iam_policy_document.allow_triggering_codepipeline.json
}

data "aws_iam_policy_document" "allow_triggering_codepipeline" {
    statement {
      effect = "Allow"
      actions = ["codepipeline:StartPipelineExecution"]
      resources = ["arn:aws:codepipeline:eu-west-2:711966560482:*"]
    }
}