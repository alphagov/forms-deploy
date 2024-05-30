output "sns_topic_alert_pagerduty" {
  value       = aws_sns_topic.alert_pagerduty
  description = "SNS topic for PagerDuty"
}
