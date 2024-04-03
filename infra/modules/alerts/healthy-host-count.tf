resource "aws_cloudwatch_metric_alarm" "healthy_host_alarms" {
  for_each = data.aws_lb_target_group.target_groups

  alarm_name          = "alb_healthy_host_count_${each.value.name}"
  alarm_description   = "Less than ${var.minimum_healthy_host_count} healthy instances of ${each.value.name}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HealthyHostCount"
  statistic           = "Minimum"
  // TODO: Review standard vs high resolution period change
  period              = 60
  threshold           = var.minimum_healthy_host_count

  dimensions = {
    LoadBalancer = data.aws_lb.alb.arn_suffix
    TargetGroup  = each.value.arn_suffix
  }

  actions_enabled = var.enable_alert_actions
  alarm_actions   = [aws_sns_topic.alert_topic.arn]
  ok_actions      = [aws_sns_topic.alert_topic.arn]
}
