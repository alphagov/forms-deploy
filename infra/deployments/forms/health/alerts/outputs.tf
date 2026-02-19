output "healthy_host_count_alarm_names" {
  value       = { for k, v in aws_cloudwatch_metric_alarm.healthy_host_alarms : k => v.alarm_name }
  description = "The names of the alarms configured to monitor the number of healthy hosts in each load balancer target group "
}

output "alert_severity" {
  value       = local.alert_severity
  description = "Alert severity is a collection of maps from severity level to the channel that should be used for that severity"
}
