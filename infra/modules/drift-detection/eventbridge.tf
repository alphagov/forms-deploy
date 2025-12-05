resource "aws_cloudwatch_event_rule" "drift_check_schedule" {
  name                = "drift-check-${var.deployment_name}"
  description         = "Triggers drift detection for ${var.deployment_name} deployment"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "start_drift_check" {
  #checkov:skip=CKV2_FORMS_AWS_6:Dead Letter Queue will be added when needed
  rule      = aws_cloudwatch_event_rule.drift_check_schedule.name
  target_id = "StartDriftCheck"
  arn       = aws_codebuild_project.drift_check.arn
  role_arn  = aws_iam_role.eventbridge.arn
}
