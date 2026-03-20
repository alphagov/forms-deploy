resource "aws_cloudwatch_metric_alarm" "schedule_weekly_batch_deliveries_job_not_run" {
  alarm_name          = "${var.environment}-schedule-weekly-batch-deliveries-job-not-run"
  alarm_description   = <<EOF
    The forms-runner job to schedule weekly batch submission deliveries has not run in the ${var.environment} environment
    in over 7 days. It is expected that the job is run once a week on Monday. This job is run by Solid Queue, which is
    started in the forms-runner-queue-worker ECS task.

    NEXT STEPS:
    1. Check the Splunk logs and Sentry for any errors running the job.
    2. Restart the forms-runner-queue-worker ECS tasks and check whether the job starts running.

EOF
  comparison_operator = "LessThanOrEqualToThreshold"
  # There are 8 3-hour periods in a day, so we check for 8 * 7 = 56 periods to cover 7 days, plus 1 more period to allow
  # for some delay in the job running
  evaluation_periods = 8 * 7 + 1
  metric_name        = "Started"
  namespace          = "Forms/Jobs"
  period             = 3 * 60 * 60 # 3 hours
  statistic          = "SampleCount"
  threshold          = 0

  dimensions = {
    Environment = "${var.environment}"
    ServiceName = "forms-runner"
    JobName     = "ScheduleWeeklyBatchDeliveriesJob"
  }

  treat_missing_data = "breaching"

  alarm_actions = [local.alert_severity.eu_west_2.info]
  ok_actions    = [local.alert_severity.eu_west_2.info]
}
