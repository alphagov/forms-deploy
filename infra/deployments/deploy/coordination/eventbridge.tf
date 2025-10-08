data "aws_cloudwatch_event_bus" "default" {
  name = "default"
}

data "aws_iam_policy_document" "allow_receiving_from_other_accounts" {
  dynamic "statement" {
    for_each = module.other_accounts.environment_accounts_id

    content {
      sid    = "AllowEventsFrom${replace(statement.key, "-", "")}"
      effect = "Allow"
      actions = [
        "events:PutEvents"
      ]
      resources = [data.aws_cloudwatch_event_bus.default.arn]
      principals {
        type        = "AWS"
        identifiers = ["arn:aws:iam::${statement.value}:root"]
      }
    }
  }
}

data "aws_iam_policy_document" "allow_sending_events_to_other_accounts" {
  dynamic "statement" {
    for_each = module.other_accounts.environment_accounts_id

    content {
      sid    = "AllowEventsTo${replace(statement.key, "-", "")}"
      effect = "Allow"
      actions = [
        "events:PutEvents"
      ]
      resources = ["arn:aws:events:eu-west-2:${statement.value}:event-bus/default"]
    }
  }
}

resource "aws_cloudwatch_event_bus_policy" "default_bus_policy" {
  policy         = data.aws_iam_policy_document.allow_receiving_from_other_accounts.json
  event_bus_name = "default"
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

resource "aws_iam_role_policy" "allow_sending_to_other_accounts" {
  name   = "allow_sending_events_to_other_accounts"
  role   = aws_iam_role.eventbridge_actor.id
  policy = data.aws_iam_policy_document.allow_sending_events_to_other_accounts.json
}
