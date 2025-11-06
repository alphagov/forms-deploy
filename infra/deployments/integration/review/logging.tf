resource "aws_cloudwatch_log_group" "review_apps" {
  #checkov:skip=CKV_AWS_338:We're happy with 30 days retention for now
  #checkov:skip=CKV_AWS_158:Default AWS SSE is sufficient, no need for CM KMS.
  name              = "/aws/ecs/review-apps"
  retention_in_days = 30
}
