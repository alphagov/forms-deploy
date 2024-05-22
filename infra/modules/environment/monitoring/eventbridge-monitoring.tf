locals {
  # We have configured AWS ChatBot for sending messages to Slack.
  # AWS ChatBot does not have an API we can use in Terraform, so we
  # configured it by hand in the one place and hardcoded the SNS topic here.
  chatbot_alerts_channel_sns_topic = "arn:aws:sns:eu-west-2:711966560482:CodeStarNotifications-govuk-forms-alert-b7410628fe547543676d5dc062cf342caba48bcd"
}

data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_metric_alarm" "event_bridge_dlq_delivery_alarm" {
  alarm_name        = "${var.environment_name}-event-bridge-delivered-dead-letters"
  alarm_description = <<EOF
    When EventBridge fails to invoke a target, it will log information about
    why it failed to invoke it and what happened in a message delivered to a
    dead letter queue in ${var.environment_type}.

    This alarm will enter the alarm state when there is a new message on the
    queue.

    NEXT STEPS:
    1. Log into the ${var.environment_type} account
    
    2. Go look at the message in SQS console by visiting the URL below and
    presing "Poll for messages". Error details are found in the message "Attributes" tab.

    https://eu-west-2.console.aws.amazon.com/sqs/v3/home?region=eu-west-2#/queues/${urlencode("https://sqs.eu-west-2.amazonaws.com/${data.aws_caller_identity.current.account_id}/${var.environment_name}-eventbridge-dead-letter-queue")}/send-receive

    3. When you've resolved the problem, delete the message from the queue
    EOF

  namespace           = "AWS/Events"
  metric_name         = "InvocationsSentToDlq"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  statistic           = "Sum"
  period              = 60 * 60 # 1 hour buckets
  evaluation_periods  = 24      # Across 24 hours
  datapoints_to_alarm = 1

  treat_missing_data = "notBreaching"

  alarm_actions = [local.chatbot_alerts_channel_sns_topic]
}