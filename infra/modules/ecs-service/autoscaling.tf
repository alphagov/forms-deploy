resource "aws_appautoscaling_target" "scaling_target" {
  max_capacity       = var.scaling_rules.max_capacity
  min_capacity       = var.scaling_rules.min_capacity
  resource_id        = "service/forms-${var.env_name}/${aws_ecs_service.app_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "scale_out" {
  name               = "${var.env_name}-${var.application}-scale-out-policy"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.scaling_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type          = "PercentChangeInCapacity"
    cooldown                 = var.scaling_rules.scale_out_cooldown
    min_adjustment_magnitude = 3
    metric_aggregation_type  = "Average"

    # 0-1000% above threshold
    # add 10%
    step_adjustment {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 1000
      scaling_adjustment          = 10
    }

    # 1000-infinity% above threshold
    # add 300%
    step_adjustment {
      metric_interval_lower_bound = 1000
      scaling_adjustment          = 300
    }
  }
}

resource "aws_appautoscaling_policy" "scale_in" {
  name               = "${var.env_name}-${var.application}-scale-in-policy"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.scaling_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type          = "PercentChangeInCapacity"
    cooldown                 = var.scaling_rules.scale_in_cooldown
    min_adjustment_magnitude = 3
    metric_aggregation_type  = "Average"

    # 0-25% below threshold
    # subtract 25%
    step_adjustment {
      metric_interval_lower_bound = -25
      metric_interval_upper_bound = 0
      scaling_adjustment          = -25
    }

    # 25-infinity% below threshold
    # subtract 50%
    step_adjustment {
      metric_interval_upper_bound = -25
      scaling_adjustment          = -50
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "service_target_response_time_high" {
  alarm_name        = "${var.env_name}-${var.application}-target-response-time-high"
  alarm_description = "P95 target response time >= ${var.scaling_rules.p95_response_time_scaling_threshold_seconds}s"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = var.scaling_rules.p95_response_time_scaling_threshold_seconds
  period              = 10
  evaluation_periods  = 2

  namespace          = "AWS/ApplicationELB"
  metric_name        = "TargetResponseTime"
  extended_statistic = "p95"
  dimensions = {
    "TargetGroup"  = aws_lb_target_group.tg.arn_suffix
    "LoadBalancer" = var.alb_arn_suffix
  }

  alarm_actions = [aws_appautoscaling_policy.scale_out.arn]
}

resource "aws_cloudwatch_metric_alarm" "service_target_response_time_low" {
  alarm_name        = "${var.env_name}-${var.application}-target-response-time-low"
  alarm_description = "P95 target response time <= 0.5s"

  comparison_operator = "LessThanOrEqualToThreshold"
  threshold           = 0.5
  period              = 10
  evaluation_periods  = 2
  dimensions = {
    "TargetGroup"  = aws_lb_target_group.tg.arn_suffix
    "LoadBalancer" = var.alb_arn_suffix
  }

  namespace          = "AWS/ApplicationELB"
  metric_name        = "TargetResponseTime"
  extended_statistic = "p95"

  alarm_actions = [aws_appautoscaling_policy.scale_in.arn]
}
