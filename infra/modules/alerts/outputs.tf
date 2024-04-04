output "healthy_host_alarm_name" {
  description = "The alarm name for for healthy host alarm"
  value       = aws_cloudwatch_metric_alarm.healthy_host_alarms.alarm_name
}