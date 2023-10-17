data "aws_sqs_queue" "ses_bounces_and_complaints_queue" {
  name = "ses_bounces_and_complaints_queue"
}

resource "aws_cloudwatch_metric_alarm" "ses_bounces_and_complaints_queue_alarm" {
  alarm_name          = "ses_bounces_and_complaints_queue_alarm"
  alarm_description   = "Any complaints of bounces in the SQS queue for SES."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  statistic           = "Minimum"
  period              = 30
  threshold           = 1

  dimensions = {
    QueueName = data.ses_bounces_and_complaints_queue.name
  }

  alarm_actions = [aws_sns_topic.alert_topic.arn]
  ok_actions    = [aws_sns_topic.alert_topic.arn]
}
