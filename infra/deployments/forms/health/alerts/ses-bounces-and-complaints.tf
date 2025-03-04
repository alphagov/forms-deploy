data "aws_sqs_queue" "ses_bounces_and_complaints_queue" {
  name = "ses_bounces_and_complaints_queue"
}

resource "aws_cloudwatch_metric_alarm" "ses_bounces_and_complaints_queue_buildup" {
  alarm_name          = "ses_bounces_and_complaints_queue_buildup"
  alarm_description   = <<EOF
    There is a queue buildup in ${data.aws_sqs_queue.ses_bounces_and_complaints_queue.name} in the ${var.environment} account.

    When SES sends an email to a user and the email bounces or is marked as spam ('complaints'),
    SES will log the event as a message on an SQS queue. We want to avoid a buildup
    of messages on the queue.

    This alarm will enter the alarm state when there are more than 10 messages on
    the queue.

    NEXT STEPS:
    1. Go look at the message in SQS console by visiting the URL below and
    presing "Poll for messages"

    https://eu-west-2.console.aws.amazon.com/sqs/v3/home?region=eu-west-2#/queues/${urlencode("https://sqs.eu-west-2.amazonaws.com/${local.account_id}/${data.aws_sqs_queue.ses_bounces_and_complaints_queue.name}")}/send-receive

    2. Delete messages on the queue until the queue is empty

    We're exploring how we want to react to bounces/complaints. As we receive
    messages we will develop a next step process beyond deletion.
EOF
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  statistic           = "Minimum"
  period              = 600
  threshold           = 10

  dimensions = {
    foo       = local.account_id
    QueueName = data.aws_sqs_queue.ses_bounces_and_complaints_queue.name
  }
  treat_missing_data = "notBreaching"

  alarm_actions = [local.alert_severity.eu_west_2.info]
}

resource "aws_cloudwatch_metric_alarm" "ses_bounces_and_complaints_queue_contains_message" {
  alarm_name          = "ses_bounces_and_complaints_queue_contains_message"
  alarm_description   = <<EOF
    There is a message in ${data.aws_sqs_queue.ses_bounces_and_complaints_queue.name} in the ${var.environment} account.
    
    When SES sends an email to a user and the email bounces or is marked as spam ('complaints'),
    SES will log the event as a message on an SQS queue.

    This alarm will enter the alarm state when there is a new message on the queue.

    NEXT STEPS:
    1. Go look at the message in SQS console by visiting the URL below and
    presing "Poll for messages"

    https://eu-west-2.console.aws.amazon.com/sqs/v3/home?region=eu-west-2#/queues/${urlencode("https://sqs.eu-west-2.amazonaws.com/${local.account_id}/${data.aws_sqs_queue.ses_bounces_and_complaints_queue.name}")}/send-receive

    2. Delete messages on the queue until the queue is empty

    We're exploring how we want to react to bounces/complaints. As we receive
    messages we will develop a next step process beyond deletion.
EOF
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  statistic           = "Minimum"
  period              = 600
  threshold           = 1

  dimensions = {
    QueueName = data.aws_sqs_queue.ses_bounces_and_complaints_queue.name
  }
  treat_missing_data = "notBreaching"

  alarm_actions = [local.alert_severity.eu_west_2.info]
}
