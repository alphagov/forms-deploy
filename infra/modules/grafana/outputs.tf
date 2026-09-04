output "database_endpoint" {
  value = aws_rds_cluster.grafana.endpoint
}

output "athena_workgroup_name" {
  value = aws_athena_workgroup.grafana.name
}

output "task_role_arn" {
  value = aws_iam_role.task.arn
}
