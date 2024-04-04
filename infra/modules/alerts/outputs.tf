output "healthy_host_alarm_names" {
  description = "The alarm name for each healthy host (target group) alarms"
  value       = toset([for alarm in aws_cloudwatch_metric_alarm.healthy_host_alarms : alarm.alarm_name])
}