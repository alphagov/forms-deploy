resource "aws_cloudwatch_metric_alarm" "healthy_host_alarms" {
  for_each = data.aws_lb_target_group.target_groups

  alarm_name        = "alb_healthy_host_count_${each.value.name}"
  alarm_description = <<EOF
    Less than ${var.minimum_healthy_host_count} healthy instances of ${each.value.name}

    Check the application logs and ECS event logs to understand why the task stopped
  EOF

  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HealthyHostCount"
  statistic           = "Minimum"
  period              = 60
  threshold           = var.minimum_healthy_host_count

  dimensions = {
    LoadBalancer = data.aws_lb.alb.arn_suffix
    TargetGroup  = each.value.arn_suffix
  }

  actions_enabled = var.enable_alert_actions
  alarm_actions   = [var.pagerduty_alert_topics.eu_west_2]
  ok_actions      = [var.pagerduty_alert_topics.eu_west_2]
}
