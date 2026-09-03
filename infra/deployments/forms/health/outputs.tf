output "grafana_workspace_endpoint" {
  value = one(aws_grafana_workspace.this[*].endpoint)
}
