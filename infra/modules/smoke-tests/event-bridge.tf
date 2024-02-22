resource "aws_cloudwatch_event_rule" "scheduler" {
  name        = "schedule-smoke-tests"
  description = "Starts the smoke test CodeBuild project on a schedule"

  schedule_expression = "rate(${var.smoke_tests_frequency_minutes} minutes)"
}

resource "aws_cloudwatch_event_target" "smoke_tests" {
  rule      = aws_cloudwatch_event_rule.scheduler.name
  target_id = "StartSmokeTests"
  arn       = aws_codebuild_project.smoke_tests.arn
  role_arn  = aws_iam_role.event_bridge.arn
}

data "aws_iam_policy_document" "event_bridge" {
  statement {
    actions = [
      "codebuild:StartBuild",
    ]
    resources = [
      aws_codebuild_project.smoke_tests.arn
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "event_bridge" {
  name   = "event-bridge-${local.project_name}"
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
  name = "event-bridge-scheduler-${local.project_name}"

  assume_role_policy = data.aws_iam_policy_document.event_bridge_service_policy.json
}

resource "aws_iam_role_policy_attachment" "event_bridge" {
  policy_arn = aws_iam_policy.event_bridge.arn
  role       = aws_iam_role.event_bridge.id
}
