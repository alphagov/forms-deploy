resource "aws_cloudwatch_log_group" "review_apps" {
  #checkov:skip=CKV_AWS_338:We're happy with 30 days retention for now
  #checkov:skip=CKV_AWS_158:Default AWS SSE is sufficient, no need for CM KMS.
  name              = "/aws/ecs/review-apps"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_subscription_filter" "review_apps_csls_log_subscription" {
  count = var.send_logs_to_cyber ? 1 : 0

  name            = "csls_log_subscription"
  log_group_name  = aws_cloudwatch_log_group.review_apps.name
  filter_pattern  = "-\"/up\""
  destination_arn = "arn:aws:logs:eu-west-2:885513274347:destination:csls_cw_logs_destination_prodpython"
  depends_on = [
    aws_cloudwatch_log_group.review_apps
  ]
}
