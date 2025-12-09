module "chatbot_well_known" {
  source = "../../../../modules/well-known/chatbot"
}

locals {
  # AWS ChatBot SNS topic - managed in the deploy account (deploy/coordination/chatbot.tf)
  # Referenced via well-known module
  chatbot_alerts_channel_sns_topic = module.chatbot_well_known.alerts_topic_arn
}

resource "aws_cloudwatch_metric_alarm" "cribl_dlq_messages" {
  alarm_name          = "cribl-s3-events-dlq-has-messages"
  alarm_description   = <<EOF
When S3 notification messages fail to be processed by Cribl after 5 attempts,
they are moved to the dead letter queue. This alarm triggers when messages arrive in the DLQ.

This indicates a problem that needs investigation.

NEXT STEPS:

1. Log into the deploy account

2. Check Cribl logs for processing errors

3. Review messages in the DLQ by visiting the URL below and clicking "Poll for messages":
   https://eu-west-2.console.aws.amazon.com/sqs/v3/home?region=eu-west-2#/queues/${urlencode("https://sqs.eu-west-2.amazonaws.com/${data.aws_caller_identity.current.account_id}/${aws_sqs_queue.cribl_s3_events_dlq.name}")}/send-receive

4. Investigate and fix the root cause (check Cribl logs, S3 permissions, file corruption)

5. Once fixed, manually redrive messages from the DLQ via AWS Console or CLI:
   aws sqs start-message-move-task --source-arn ${aws_sqs_queue.cribl_s3_events_dlq.arn}

6. After successful redrive, delete any remaining messages from the DLQ
EOF
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300 # 5 minutes
  statistic           = "Average"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = aws_sqs_queue.cribl_s3_events_dlq.name
  }

  alarm_actions = [local.chatbot_alerts_channel_sns_topic]
}

resource "aws_cloudwatch_metric_alarm" "cribl_dlq_old_messages" {
  alarm_name          = "cribl-s3-events-dlq-old-messages"
  alarm_description   = <<EOF
Messages in the Cribl S3 events DLQ are older than 24 hours. This indicates that
messages have been stuck in the DLQ without investigation or resolution.

DLQ messages have a maximum retention of 14 days, after which they are permanently deleted.

NEXT STEPS:

1. Check the "cribl-s3-events-dlq-has-messages" alarm for investigation steps

2. Review why messages haven't been processed or redriven

3. Take action to either:
   - Redrive messages after fixing root cause
   - Archive/delete messages that cannot be processed

4. DLQ URL: https://eu-west-2.console.aws.amazon.com/sqs/v3/home?region=eu-west-2#/queues/${urlencode("https://sqs.eu-west-2.amazonaws.com/${data.aws_caller_identity.current.account_id}/${aws_sqs_queue.cribl_s3_events_dlq.name}")}/send-receive
EOF
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = 3600 # 1 hour
  statistic           = "Maximum"
  threshold           = 86400 # 24 hours in seconds
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = aws_sqs_queue.cribl_s3_events_dlq.name
  }

  alarm_actions = [local.chatbot_alerts_channel_sns_topic]
}
