resource "aws_cloudwatch_event_rule" "scheduler" {
  name        = "schedule-${var.test_name}-${var.environment}"
  description = "Starts the ${var.test_name} CodeBuild project on a schedule in ${var.environment}"

  schedule_expression = "rate(${var.frequency_minutes} minutes)"
}

resource "aws_cloudwatch_event_target" "test_runner" {
  #checkov:skip=CKV2_FORMS_AWS_6: Dead Letter Queue will be added when available within environment module.
  rule      = aws_cloudwatch_event_rule.scheduler.name
  target_id = "StartTest"
  arn       = aws_codebuild_project.run_test.arn
  role_arn  = aws_iam_role.event_bridge.arn
}

data "aws_iam_policy_document" "event_bridge" {
  statement {
    actions = [
      "codebuild:StartBuild",
    ]
    resources = [
      aws_codebuild_project.run_test.arn
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "event_bridge" {
  name   = "${var.environment}-event-bridge-${var.test_name}"
  path   = "/"
  policy = data.aws_iam_policy_document.event_bridge.json
}


data "aws_iam_policy_document" "event_bridge_service_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "event_bridge" {
  name = "${var.environment}-event-bridge-scheduler-${var.test_name}"

  assume_role_policy = data.aws_iam_policy_document.event_bridge_service_policy.json
}

resource "aws_iam_role_policy_attachment" "event_bridge" {
  policy_arn = aws_iam_policy.event_bridge.arn
  role       = aws_iam_role.event_bridge.id
}
