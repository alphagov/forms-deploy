data "aws_cloudwatch_event_bus" "default" {
  name = "default"
}

data "aws_iam_policy_document" "allow_receiving_from_deploy_account" {
  statement {
    sid    = "AllowEventsFromDeployAcct"
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

resource "aws_cloudwatch_event_bus_policy" "default_bus_policy" {
  policy         = data.aws_iam_policy_document.allow_receiving_from_deploy_account.json
  event_bus_name = "default"
}

resource "aws_cloudwatch_log_group" "ecr_push_events" {
  name              = "/aws/events/${var.environment_name}/ecr-events"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_resource_policy" "allow_delivery_from_eventbridge" {
  policy_document = data.aws_iam_policy_document.log_group_policy.json
  policy_name     = "eventbridge-publishing-policy"
}

resource "aws_cloudwatch_event_rule" "ecr_push_events" {
  name        = "all-ecr-push-events-${var.environment_name}"
  description = "Matches all ECR push events"
  event_pattern = jsonencode({
    source = ["aws.ecr", "uk.gov.service.forms"]
    detail = {
      action-type = ["PUSH"]
    }
  })
}

resource "aws_cloudwatch_event_target" "log_events_to_cloudwatch" {
  target_id = "${var.environment_name}-log-to-cloudwatch"
  rule      = aws_cloudwatch_event_rule.ecr_push_events.name
  arn       = aws_cloudwatch_log_group.ecr_push_events.arn
}

data "aws_iam_policy_document" "log_group_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.ecr_push_events.arn}:*"
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