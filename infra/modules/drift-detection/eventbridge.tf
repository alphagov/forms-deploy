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

resource "aws_cloudwatch_event_rule" "drift_check_failure" {
  count       = var.drift_detected_topic_arn != null ? 1 : 0
  name        = "drift-check-${var.deployment_name}-failure"
  description = "Notifies when drift is detected in ${var.deployment_name} deployment"

  event_pattern = jsonencode({
    source      = ["aws.codebuild"]
    detail-type = ["CodeBuild Build State Change"]
    detail = {
      build-status = ["FAILED"]
      project-name = [aws_codebuild_project.drift_check.name]
    }
  })
}

resource "aws_cloudwatch_event_target" "send_drift_failure_to_sns" {
  #checkov:skip=CKV2_FORMS_AWS_6:Dead Letter Queue not needed for drift detection notifications
  count     = var.drift_detected_topic_arn != null ? 1 : 0
  target_id = "send-to-sns"
  rule      = aws_cloudwatch_event_rule.drift_check_failure[0].name
  arn       = var.drift_detected_topic_arn

  input_transformer {
    input_paths = {
      project_name = "$.detail.project-name"
      build_id     = "$.detail.build-id"
      region       = "$.region"
      account      = "$.account"
    }
    input_template = <<EOF
{
  "version": "1.0",
  "source": "custom",
  "content": {
    "textType": "client-markdown",
    "title": ":warning: Terraform Drift Detected: ${var.deployment_name}",
    "description": "Drift has been detected in the **${var.deployment_name}** deployment. Some Terraform roots have changes that need to be applied.\n\nPlease review the drift detection logs and reapply the affected roots.",
    "keywords": [
      "drift-detection",
      "${var.deployment_name}",
      "terraform"
    ],
    "nextSteps": [
      "https://<region>.console.aws.amazon.com/codesuite/codebuild/projects/<project_name>/history?region=<region>"
    ]
  }
}
EOF
  }
}
