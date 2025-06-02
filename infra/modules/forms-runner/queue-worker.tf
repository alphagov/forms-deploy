locals {
  queue_worker_name = "forms-runner-queue-worker"
}

resource "aws_ssm_parameter" "queue_worker_sentry_dsn" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key
  name  = "/${local.queue_worker_name}-${var.env_name}/sentry/dsn"
  type  = "SecureString"
  value = "dummy_value"

  description = "Sentry DSN value for ${local.queue_worker_name} in the ${var.env_name} environment"

  lifecycle {
    ignore_changes  = [value]
    prevent_destroy = true
  }
}