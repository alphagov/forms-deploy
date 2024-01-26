data "aws_cloudwatch_event_bus" "default" {
  name = "default"
}
data "aws_iam_policy_document" "allow_receiving_from_deploy_account" {
  statement {
    sid    = "AllowReceivingEventsFromDeployAccount"
    effect = "Allow"
    actions = [
      "events:PutEvents"
    ]
    resources = [data.aws_cloudwatch_event_bus.default.arn]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::711966560482:root"]
    }
  }
}

data "aws_iam_policy_document" "allow_sending_to_deploy_account" {
  statement {
    sid    = "AllowSendingEventsToDeployAccount"
    effect = "Allow"
    actions = [
      "events:PutEvents"
    ]
    resources = ["arn:aws:events:eu-west-2:711966560482:event-bus/default"]
  }
}

data "aws_iam_policy_document" "allow_triggering_codepipeline" {
  statement {
    effect    = "Allow"
    actions   = ["codepipeline:StartPipelineExecution"]
    resources = ["arn:aws:codepipeline:eu-west-2:::pipeline/*"]
  }
}

resource "aws_iam_role" "eventbridge_actor" {
  name               = "${var.env_name}-event-bridge-actor"
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

resource "aws_iam_role_policy" "allow_sending_to_deploy_account" {
  name   = "allow_sending_to_deploy_account"
  role   = aws_iam_role.eventbridge_actor.id
  policy = data.aws_iam_policy_document.allow_sending_to_deploy_account.json
}

resource "aws_iam_role_policy" "allow_triggering_codepipeline" {
  name   = "allow_triggering_codepipeline"
  role   = aws_iam_role.eventbridge_actor.id
  policy = data.aws_iam_policy_document.allow_triggering_codepipeline.json
}

resource "aws_cloudwatch_event_bus_policy" "default_bus_policy" {
  policy         = data.aws_iam_policy_document.allow_receiving_from_deploy_account.json
  event_bus_name = "default"
}

resource "aws_cloudwatch_event_rule" "match_all_codepipeline_events" {
  name        = "send_all_codepipeline_events_to_deploy"
  description = "Send all CodePipeline events to the deploy account"
  role_arn    = aws_iam_role.eventbridge_actor.arn

  event_bus_name = "default"
  event_pattern = jsonencode({
    source = ["aws.codepipeline"]
  })
}

resource "aws_cloudwatch_event_target" "deploy_account_bus" {
  rule      = aws_cloudwatch_event_rule.match_all_codepipeline_events.name
  target_id = "send_to_deploy_account_bus"
  arn       = "arn:aws:events:eu-west-2:711966560482:event-bus/default"
  role_arn  = aws_iam_role.eventbridge_actor.arn
}