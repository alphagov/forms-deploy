resource "aws_cloudwatch_metric_alarm" "ecs_memory_utilization" {
  for_each = toset(local.apps)

  alarm_name          = "ecs-${each.value}-${var.environment}_memory_utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This metric checks the memory utilization of the ECS service: ${each.value} in ${var.environment} environment"

  dimensions = {
    ClusterName = data.aws_ecs_cluster.cluster_name.id
    ServiceName = each.value
  }

  alarm_actions      = [local.chatbot_alerts_channel_sns_topic]
  ok_actions         = [local.chatbot_alerts_channel_sns_topic]
  treat_missing_data = "missing"
}
