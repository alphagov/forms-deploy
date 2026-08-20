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
  alarm_description   = <<EOF
  The ECS service ${each.value} in ${var.environment} environment is using more than 70% of memory.

  There are multiple things that could cause this and you need to investigate.

  This is a non-exenstive list of things to check:
  - The ECS service in the AWS Console to understand when the memory usage started increasing: is it gradual (it may a memory leak) or sudden (it may a spike in traffic)? does it coincide with any deployments? has it decreased or is it continuing to increase?
  - Redis Evictions (in CloudWatch, either by exploring metrics or in our Overview Dashboard). Redis evictions will happen when the memory utilization reaches 100%. This likely indicates that users are impacted. For example, someone in the process of filling in a form may lose all their data.
EOF
  dimensions = {
    ClusterName = data.aws_ecs_cluster.cluster_name.cluster_name
    ServiceName = each.value
  }

  actions_enabled    = var.enable_alert_actions
  alarm_actions      = [local.alert_severity.eu_west_2.warn]
  ok_actions         = [local.alert_severity.eu_west_2.warn]
  treat_missing_data = "missing"
}
