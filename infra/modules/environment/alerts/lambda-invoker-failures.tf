locals {
  # We have configured AWS ChatBot for sending messages to Slack.
  # AWS ChatBot does not have an API we can use in Terraform, so we
  # configured it by hand in the one place and hardcoded the SNS topic here.
  chatbot_alerts_channel_sns_topic = "arn:aws:sns:eu-west-2:711966560482:CodeStarNotifications-govuk-forms-alert-b7410628fe547543676d5dc062cf342caba48bcd"
}

resource "aws_cloudwatch_metric_alarm" "pipeline_invoker_failure" {
  alarm_name          = "pipeline-invoker-failed-invocation"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = <<EOF
    We have a Lambda (pipeline_invoker) which receives events from AWS EventBridge and invokes CodePipeline.
    We use it to trigger the production pipelines when the staging pipelines have completed.

    This alarm will enter the alarm state when CloudWatch metrics records an error in the Lambda, indicating a
    failed invocation.

    NEXT STEPS:
    1. Navigate to the Lambda "Monitoring" tab to view invocations, error count, and links to Lambda logs in CloudWatch:

    https://eu-west-2.console.aws.amazon.com/lambda/home?region=eu-west-2#/functions/${urlencode("${var.environment}")}-pipeline-invoker?tab=monitoring

    2. From "Monitoring" tab click "View in CloudWatch logs" to review logs and diagnose errors.
    3. To test a solution, invoke the Lambda by running the relevant pipeline and look for any further failed invocations or errors.

EOF

  dimensions = {
    FunctionName = "${var.environment}-pipeline-invoker"
  }

  alarm_actions = [local.chatbot_alerts_channel_sns_topic]
}

resource "aws_cloudwatch_metric_alarm" "paused_pipeline_detector_failure" {
  alarm_name          = "paused-pipeline-detector-failed-invocation"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = <<EOF
    We have a Lambda (${var.environment}-paused-pipeline-detection) which periodically looks for pipelines which have
    been paused for too long.

    This alarm will enter the alarm state when CloudWatch metrics records an error in the Lambda, indicating a
    failed invocation.

    NEXT STEPS:
    1. Navigate to the Lambda "Monitoring" tab to view invocations, error count, and links to Lambda logs in CloudWatch:

    https://eu-west-2.console.aws.amazon.com/lambda/home?region=eu-west-2#/functions/${urlencode("${var.environment}")}-paused-pipeline-detection?tab=monitoring

    2. From "Monitoring" tab click "View in CloudWatch logs" to review logs and diagnose errors.
    3. To test a solution, invoke the Lambda by using the test feature in the AWS Lambda console

EOF

  dimensions = {
    FunctionName = "${var.environment}-paused-pipeline-detection"
  }

  alarm_actions = [local.chatbot_alerts_channel_sns_topic]
}

