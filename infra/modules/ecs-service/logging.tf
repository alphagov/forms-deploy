resource "aws_cloudwatch_log_group" "log" {
  #checkov:skip=CKV_AWS_338:We're happy with 30 days retention for now
  #checkov:skip=CKV_AWS_158:Default AWS SSE is sufficient, no need for CM KMS.
  name              = "${var.application}-${var.env_name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_subscription_filter" "csls_log_subscription" {
  name            = "csls_log_subscription"
  log_group_name  = "${var.application}-${var.env_name}"
  filter_pattern  = "-\"deprecated\""
  destination_arn = "arn:aws:logs:eu-west-2:885513274347:destination:csls_cw_logs_destination_prodpython"
  depends_on = [
    aws_cloudwatch_log_group.log
  ]
}

resource "aws_cloudwatch_log_subscription_filter" "via_cribl_to_splunk" {
  name = "via-cribl-to-splunk"

  log_group_name = aws_cloudwatch_log_group.log.name

  filter_pattern  = ""
  destination_arn = var.log_to_splunk_settings.kinesis_destination_arn
  distribution    = "ByLogStream"
  role_arn        = var.log_to_splunk_settings.kinesis_subscription_role_arn
}
