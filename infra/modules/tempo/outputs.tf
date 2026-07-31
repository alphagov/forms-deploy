output "grafana_url" {
  value       = "https://tempo.${var.root_domain}"
  description = "The public URL for the Grafana UI"
}

output "otlp_http_endpoint" {
  value       = "http://tempo-otlp.internal.${var.root_domain}"
  description = "The internal OTLP/HTTP endpoint other services should send traces to"
}

output "mimir_internal_url" {
  value       = local.mimir_internal_url
  description = "The internal URL for Mimir - used by tempo's metrics_generator remote_write and grafana's datasource"
}

output "trace_bucket_name" {
  value = module.trace_storage.name
}

output "tempo_ecr_repository_url" {
  value = aws_ecr_repository.tempo.repository_url
}

output "grafana_ecr_repository_url" {
  value = aws_ecr_repository.grafana.repository_url
}
