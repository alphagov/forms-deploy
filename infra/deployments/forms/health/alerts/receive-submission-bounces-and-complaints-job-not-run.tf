resource "aws_cloudwatch_metric_alarm" "receive_submission_bounces_and_complaints_job_not_run" {
  alarm_name          = "${var.environment}-receive-submission-bounces-and-complaints-job-not-run"
  alarm_description   = <<EOF
    The forms-runner job to receive SQS notifications about bounces and complaints has not run in the ${var.environment}
    environment in the past 30 minutes. It is expected that the job is run every 10 minutes. This job is run by Solid
    Queue, which is started in the forms-runner-queue-worker ECS task.

    NEXT STEPS:
    1. Check the Splunk logs and Sentry for any errors running the job.
    2. Restart the forms-runner-queue-worker ECS tasks and check whether the job starts running.

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
    JobName     = "ReceiveSubmissionBouncesAndComplaintsJob"
  }

  treat_missing_data = "breaching"

  alarm_actions = [local.alert_severity.eu_west_2.info]
  ok_actions    = [local.alert_severity.eu_west_2.info]
}
