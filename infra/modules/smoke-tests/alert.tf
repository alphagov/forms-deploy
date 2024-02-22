locals {
  chatbot_alerts_channel_sns_topic = "arn:aws:sns:eu-west-2:711966560482:CodeStarNotifications-govuk-forms-alert-b7410628fe547543676d5dc062cf342caba48bcd"
}

resource "aws_cloudwatch_metric_alarm" "failing_smoke_tests" {
  alarm_name          = "scheduled_smoke_tests_failing"
  alarm_description   = "Scheduled smoke tests are failing"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  namespace           = "AWS/CodeBuild"
  metric_name         = "FailedBuilds"
  statistic           = "Sum"
  period              = (var.smoke_tests_frequency_minutes * 60)
  threshold           = 1


  dimensions = {
    ProjectName = aws_codebuild_project.smoke_tests.name
  }

  actions_enabled = false
  alarm_actions   = [local.chatbot_alerts_channel_sns_topic]
  ok_actions      = [local.chatbot_alerts_channel_sns_topic]
}

resource "aws_cloudwatch_metric_alarm" "smoke_tests_not_running" {
  alarm_name          = "scheduled_smoke_tests_not_running"
  alarm_description   = "Scheduled smoke tests are not running"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  namespace           = "AWS/CodeBuild"
  metric_name         = "Builds"
  statistic           = "Sum"
  period              = (var.smoke_tests_frequency_minutes * 60)
  threshold           = 1


  dimensions = {
    ProjectName = aws_codebuild_project.smoke_tests.name
  }

  actions_enabled = false
  alarm_actions   = [local.chatbot_alerts_channel_sns_topic]
  ok_actions      = [local.chatbot_alerts_channel_sns_topic]
}
