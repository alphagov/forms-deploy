output "database_endpoint" {
  value = aws_rds_cluster.grafana.endpoint
}

output "athena_workgroup_name" {
  value = aws_athena_workgroup.grafana.name
}

output "task_role_arn" {
  value = aws_iam_role.task.arn
}

output "alb_dns_name" {
  value = aws_lb.grafana.dns_name
}

output "alb_zone_id" {
  value = aws_lb.grafana.zone_id
}

output "target_group_arn" {
  value = aws_lb_target_group.grafana.arn
}
