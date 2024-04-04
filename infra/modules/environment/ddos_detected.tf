resource "aws_cloudwatch_metric_alarm" "ddos_detected" {
  provider            = aws.us-east-1
  alarm_name          = "ddos_detected_in_${var.env_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DDoSDetected"
  namespace           = "AWS/DDoSProtection"
  period              = 300
  statistic           = "Sum"
  threshold           = 0

  actions_enabled = false
}