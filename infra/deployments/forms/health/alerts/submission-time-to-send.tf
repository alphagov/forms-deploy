resource "aws_cloudwatch_metric_alarm" "submission_time_to_send" {
  alarm_name          = "${var.environment}-submission-time-to-send"
  alarm_description   = <<EOF
    The average time to send a submission from the time it was scheduled to be sent is greater than 1 minute in
    the ${var.environment} environment. This suggests that we are unable to keep up with demand for the number of
    submissions we need to process. The job to send submission emails is run by Solid Queue, which is started in the
    forms-runner-queue-worker ECS task.

    NEXT STEPS:
    1. Search in Splunk for "event=form_submission_email_sent" to see the rate of submission emails being sent and the
    times taken.
    2. Look at the CloudWatch FormSubmissions dashboard to view metrics for the submissions queue:
    https://eu-west-2.console.aws.amazon.com/cloudwatch/home?region=eu-west-2#dashboards/dashboard/FormSubmissions
EOF
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "TimeToSendSubmission"
  namespace           = "Forms/Jobs"
  period              = 30 * 60 # 30 minutes
  unit                = "Milliseconds"
  extended_statistic  = "p95"
  threshold           = 60 * 1000 # 1 minute

  dimensions = {
    Environment = "${var.environment}"
    ServiceName = "forms-runner"
    JobName     = "SendSubmissionJob"
  }

  treat_missing_data = "notBreaching"

  alarm_actions = [local.alert_severity.eu_west_2.warn]
  ok_actions    = [local.alert_severity.eu_west_2.warn]
}
