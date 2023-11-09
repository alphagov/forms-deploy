resource "aws_appautoscaling_target" "scaling_target" {
  max_capacity       = var.scaling_rules.max_capacity
  min_capacity       = var.scaling_rules.min_capacity
  resource_id        = "service/${data.aws_ecs_cluster.forms.name}/${aws_ecs_service.app_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu_scaling_policy" {
  name               = "${var.env_name}-${var.application}-cpu-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.scaling_rules.cpu_usage_target_pct
    scale_in_cooldown  = var.scaling_rules.scale_in_cooldown
    scale_out_cooldown = var.scaling_rules.scale_out_cooldown
  }
}