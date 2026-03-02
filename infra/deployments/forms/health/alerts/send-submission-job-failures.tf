resource "aws_cloudwatch_metric_alarm" "send_submission_job_failures" {
  alarm_name          = "${var.environment}-send-submission-job-failures"
  alarm_description   = <<EOF
    The forms-runner job to send submissions has failed more than 10 times in the last 15 minutes in the
    ${var.environment} environment. This job is run by Solid Queue, which is started in the forms-runner-queue-worker
    ECS task.

    NEXT STEPS:
    1. Check whether there are any forms-runner errors in Sentry related to the SendSubmissionJob. We retry the job
    automatically if there are errors calling AWS, but for all other errors we immediately send the error to Sentry and
    the job is not scheduled for retry.

    If there are no errors in Sentry, check the Splunk logs for the exception messages if the job has been retried.
    Search for "Retrying SendSubmissionJob" to find these log lines.

    2. If the failed jobs have not been scheduled to be retried, you will need to manually trigger resending the
    submission.
EOF
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Failure"
  namespace           = "Forms/Jobs"
  period              = 900
  statistic           = "Sum"
  threshold           = 10

  dimensions = {
    Environment = "${var.environment}"
    ServiceName = "forms-runner"
    JobName     = "SendSubmissionJob"
  }

  treat_missing_data = "notBreaching"

  alarm_actions = [local.alert_severity.eu_west_2.warn]
  ok_actions    = [local.alert_severity.eu_west_2.warn]
}
