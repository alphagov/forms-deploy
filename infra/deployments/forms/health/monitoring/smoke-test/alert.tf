resource "aws_cloudwatch_metric_alarm" "failing" {
  alarm_name          = "${var.test_name}-failing"
  alarm_description   = var.alarm_description
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  namespace           = "AWS/CodeBuild"
  metric_name         = "FailedBuilds"
  statistic           = "Sum"
  period              = (var.frequency_minutes * 60)
  threshold           = 1

  dimensions = {
    ProjectName = aws_codebuild_project.run_test.name
  }

  actions_enabled = var.enable_alerting
  alarm_actions   = [var.alarm_sns_topic_arn]
  ok_actions      = [var.alarm_sns_topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "not_running" {
  alarm_name          = "${var.test_name}-not-running"
  alarm_description   = "${var.test_name} in ${var.environment} are not running. Investigate to get the tests running again."
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  namespace           = "AWS/CodeBuild"
  metric_name         = "Builds"
  statistic           = "Sum"
  period              = (var.frequency_minutes * 60)
  threshold           = 1

  treat_missing_data = "breaching"

  dimensions = {
    ProjectName = aws_codebuild_project.run_test.name
  }

  actions_enabled = var.enable_alerting
  alarm_actions   = [var.alarm_sns_topic_arn]
  ok_actions      = [var.alarm_sns_topic_arn]
}
