resource "aws_cloudwatch_metric_alarm" "lb_target_group_response_time" {
  for_each = data.aws_lb_target_group.target_groups

  alarm_name          = "alb_target_group_response_time_${each.value.name}"
  alarm_description   = "${each.value.name} p95 response time is in excess of 1s"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  namespace           = "AWS/ApplicationELB"
  metric_name         = "TargetResponseTime"
  extended_statistic  = "p95"
  period              = (5 * 60)
  threshold           = 1000


  dimensions = {
    LoadBalancer = data.aws_lb.alb.arn_suffix
    TargetGroup  = each.value.arn_suffix
  }

  actions_enabled    = var.enable_alert_actions
  treat_missing_data = "ignore"
  alarm_actions      = [local.alert_severity.eu_west_2.high]
  ok_actions         = [local.alert_severity.eu_west_2.high]
}
