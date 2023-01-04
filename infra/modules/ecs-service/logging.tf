resource "aws_cloudwatch_log_group" "log" {
  #checkov:skip=CKV_AWS_158:Default AWS SSE is sufficient, no need for CM KMS.
  name              = "${var.application}-${var.env_name}"
  retention_in_days = 14
}

