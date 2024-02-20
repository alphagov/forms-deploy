resource "aws_cloudwatch_log_group" "log_group" {
  #checkov:skip=CKV_AWS_338:We're happy with 30 days retention for now
  #checkov:skip=CKV_AWS_158:Amazon managed SSE is sufficient.

  name              = "codebuild/${local.project_name}"
  retention_in_days = 30
}