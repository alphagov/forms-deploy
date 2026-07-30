resource "aws_cloudwatch_log_group" "tempo" {
  #checkov:skip=CKV_AWS_338:We're happy with 30 days retention for now
  #checkov:skip=CKV_AWS_158:Default AWS SSE is sufficient, no need for CM KMS.
  name              = "/aws/ecs/tempo-${var.env_name}/tempo"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "grafana" {
  #checkov:skip=CKV_AWS_338:We're happy with 30 days retention for now
  #checkov:skip=CKV_AWS_158:Default AWS SSE is sufficient, no need for CM KMS.
  name              = "/aws/ecs/tempo-${var.env_name}/grafana"
  retention_in_days = 30
}
