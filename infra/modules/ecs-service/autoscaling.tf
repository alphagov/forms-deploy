resource "aws_appautoscaling_target" "scaling_target" {
  max_capacity       = var.scaling_rules.max_capacity
  min_capacity       = var.scaling_rules.min_capacity
  resource_id        = "service/forms-${var.env_name}/${aws_ecs_service.app_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu_step_scale_out" {
  name               = "${var.env_name}-${var.application}-cpu-scale-out-policy"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.scaling_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type          = "PercentChangeInCapacity"
    cooldown                 = var.scaling_rules.scale_out_cooldown
    min_adjustment_magnitude = 3
    metric_aggregation_type  = "Average"

    # 0-5% above threshold
    # add 10%
    step_adjustment {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = 5
      scaling_adjustment          = 10
    }

    # 5-25% above threshold
    # add 30%
    step_adjustment {
      metric_interval_lower_bound = 5
      metric_interval_upper_bound = 25
      scaling_adjustment          = 30
    }

    # 25-50% above threshold
    # add 100%
    step_adjustment {
      metric_interval_lower_bound = 25
      metric_interval_upper_bound = 50
      scaling_adjustment          = 100
    }

    # 50-infinity% above threshold
    # add 300%
    step_adjustment {
      metric_interval_lower_bound = 50
      scaling_adjustment          = 300
    }
  }
}

resource "aws_appautoscaling_policy" "cpu_step_scale_in" {
  name               = "${var.env_name}-${var.application}-cpu-scale-in-policy"
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
    # sutract 50%
    step_adjustment {
      metric_interval_upper_bound = -25
      scaling_adjustment          = -50
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  alarm_name        = "${var.env_name}-${var.application}-cpu-high"
  alarm_description = "Average CPU utilisation is >= ${var.scaling_rules.cpu_usage_target_pct}%"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = var.scaling_rules.cpu_usage_target_pct
  period              = 60
  evaluation_periods  = 1

  namespace   = "AWS/ECS"
  metric_name = "CPUUtilization"
  statistic   = "Average"
  dimensions = {
    "ClusterName" = "forms-${var.env_name}"
    "ServiceName" = aws_ecs_service.app_service.name
  }

  alarm_actions = [aws_appautoscaling_policy.cpu_step_scale_out.arn]
}

resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  alarm_name        = "${var.env_name}-${var.application}-cpu-low"
  alarm_description = "Average CPU utilisation is <= 10%"

  comparison_operator = "LessThanOrEqualToThreshold"
  threshold           = 10
  period              = 60
  evaluation_periods  = 5
  dimensions = {
    "ClusterName" = "forms-${var.env_name}"
    "ServiceName" = aws_ecs_service.app_service.name
  }

  namespace   = "AWS/ECS"
  metric_name = "CPUUtilization"
  statistic   = "Average"

  alarm_actions = [aws_appautoscaling_policy.cpu_step_scale_in.arn]
}