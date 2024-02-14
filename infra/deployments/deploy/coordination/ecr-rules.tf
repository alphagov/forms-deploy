locals {
  ecr_push_events_pattern = jsonencode({
    source = ["aws.ecr", "uk.gov.service.forms"]
    detail = {
      action-type = ["PUSH"]
    }
  })
}
resource "aws_cloudwatch_event_rule" "distribute_ecr_events" {
  name          = "send-ecr-events-to-other-acounts"
  description   = "Send ECR events to the event buses of the other accounts"
  role_arn      = aws_iam_role.eventbridge_actor.arn
  event_pattern = local.ecr_push_events_pattern
}

resource "aws_cloudwatch_event_rule" "log_ecr_events" {
  name        = "log-ecr-events-in-cloudwatch"
  description = "Send ECR events to CloudWatch"
  event_pattern = local.ecr_push_events_pattern
}

resource "aws_cloudwatch_event_target" "other_account_event_bus" {
  for_each = local.other_accounts
  rule     = aws_cloudwatch_event_rule.distribute_ecr_events.name
  role_arn = aws_iam_role.eventbridge_actor.arn
  arn      = "arn:aws:events:eu-west-2:${each.value}:event-bus/default"
}

resource "aws_cloudwatch_log_group" "ecr_push_events" {
  name              = "/aws/events/ecr-events"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_resource_policy" "allow_delivery_from_eventbridge" {
  policy_document = data.aws_iam_policy_document.ecr_events_log_group_policy.json
  policy_name     = "eventbridge-publishing-policy"
}

resource "aws_cloudwatch_event_target" "log_ecr_push_events_to_cloudwatch" {
  target_id = "log-to-cloudwatch"
  rule      = aws_cloudwatch_event_rule.log_ecr_events.name
  arn       = aws_cloudwatch_log_group.ecr_push_events.arn
}

data "aws_iam_policy_document" "ecr_events_log_group_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:eu-west-2:711966560482:log-group:/aws/events/*"
    ]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "delivery.logs.amazonaws.com"
      ]
    }
  }
}