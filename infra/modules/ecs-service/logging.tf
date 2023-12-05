resource "aws_cloudwatch_log_group" "log" {
  #checkov:skip=CKV_AWS_338:We're happy with 14 days retention for now
  #checkov:skip=CKV_AWS_158:Default AWS SSE is sufficient, no need for CM KMS.
  name              = "${var.application}-${var.env_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_subscription_filter" "csls_log_subscription" {
  name            = "csls_log_subscription"
  log_group_name  = "${var.application}-${var.env_name}"
  filter_pattern  = "-\"/ping\""
  destination_arn = "arn:aws:logs:eu-west-2:885513274347:destination:csls_cw_logs_destination_prodpython"
  depends_on = [
    aws_cloudwatch_log_group.log
  ]
}
