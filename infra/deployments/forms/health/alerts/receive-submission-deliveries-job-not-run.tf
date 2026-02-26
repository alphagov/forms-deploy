resource "aws_cloudwatch_metric_alarm" "receive_submission_deliveries_job_not_run" {
  alarm_name          = "${var.environment}-receive-submission-deliveries-job-not-run"
  alarm_description   = <<EOF
    The forms-runner job to receive SQS notifications about submission deliveries has not in the ${var.environment}
    environment in the past 30 minutes. It is expected that the job is run every 10 minutes. This job is run by Solid
    Queue, which is started in the forms-runner ECS task.

    NEXT STEPS:
    1. Check the Splunk logs and Sentry for any errors running the job.
    2. Restart the forms-runner ECS tasks and check whether the job starts running.

EOF
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Started"
  namespace           = "Forms/Jobs"
  period              = 30 * 60
  statistic           = "SampleCount"
  threshold           = 0

  dimensions = {
    Environment = "${var.environment}"
    ServiceName = "forms-runner"
    JobName     = "ReceiveSubmissionDeliveriesJob"
  }

  treat_missing_data = "breaching"

  alarm_actions = [local.alert_severity.eu_west_2.info]
  ok_actions    = [local.alert_severity.eu_west_2.info]
}
