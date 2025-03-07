data "aws_ecs_cluster" "cluster_name" {
  cluster_name = "forms-${var.environment}"
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_utilization_alarm" {
  for_each = toset(local.apps)

  alarm_name          = "ecs-${each.value}-${var.environment}-cpu-utilization-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This metric checks the CPU utilization of the ECS service: ${each.value} in ${var.environment} environment"

  dimensions = {
    ClusterName = data.aws_ecs_cluster.cluster_name.id
    ServiceName = each.value
  }

  alarm_actions      = [local.alert_severity.eu_west_2.info]
  ok_actions         = [local.alert_severity.eu_west_2.info]
  treat_missing_data = "missing"
}
