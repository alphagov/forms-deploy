output "grafana_url" {
  value = try(module.tempo[0].grafana_url, null)
}
