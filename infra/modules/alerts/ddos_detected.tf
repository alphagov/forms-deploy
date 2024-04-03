resource "aws_cloudwatch_metric_alarm" "ddos_detected" {
  alarm_name          = "ddos_detected_in_${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DDoSDetected"
  namespace           = "AWS/DDoSProtection"
  period              = 300
  statistic           = "Sum"
  threshold           = 1

  actions_enabled = false
}