resource "aws_cloudwatch_metric_alarm" "event_bridge_dlq_delivery_alarm" {
  alarm_name        = "event-bridge-delivered-dead-letters"
  alarm_description = <<EOF
    When EventBridge fails to invoke a target, it will log information about
    why it failed to invoke it and what happened in a message delivered to a
    dead letter queue.

    This alarm will enter the alarm state when there is a new message on the
    deployer queue.

    NEXT STEPS:

    1. Log into the deployer account

    2. Review the messages in SQS console by visiting the URL below and
    presing "Poll for messages". Error details are found in the message "Attributes" tab.

    https://eu-west-2.console.aws.amazon.com/sqs/v3/home?region=eu-west-2#/queues/${urlencode("https://sqs.eu-west-2.amazonaws.com/${var.deploy_account_id}/${aws_sqs_queue.event_bridge_dlq.name}")}/send-receive

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

  alarm_actions = [aws_sns_topic.alerts_topic.arn]
}
