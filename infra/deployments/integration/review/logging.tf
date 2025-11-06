resource "aws_cloudwatch_log_group" "review_apps" {
  #checkov:skip=CKV_AWS_338:We're happy with 30 days retention for now
  #checkov:skip=CKV_AWS_158:Default AWS SSE is sufficient, no need for CM KMS.
  name              = "/aws/ecs/review-apps"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_subscription_filter" "via_cribl_to_splunk" {
  name = "via-cribl-to-splunk"

  log_group_name = aws_cloudwatch_log_group.review_apps.name

  filter_pattern  = ""
  destination_arn = data.terraform_remote_state.account.outputs.kinesis_destination_arn
  distribution    = "ByLogStream"
  role_arn        = data.terraform_remote_state.account.outputs.kinesis_subscription_role_arn
}
