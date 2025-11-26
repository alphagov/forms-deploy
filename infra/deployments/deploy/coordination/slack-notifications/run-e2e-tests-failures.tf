resource "aws_cloudwatch_event_rule" "run_e2e_tests_failure" {
  name        = "${var.account_name}-account-run-e2e-tests-failure-events"
  description = "Send run-e2e-tests failure messages to Slack"
  event_pattern = jsonencode({
    source      = ["custom"]
    detail-type = ["CodeBuild run-e2e-tests RSpec output"]
    account     = [var.account_id]
    detail = {
      build-status = ["FAILED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "send_run_e2e_tests_failure_to_slack" {
  target_id = "send-to-slack"
  rule      = aws_cloudwatch_event_rule.run_e2e_tests_failure.name
  arn       = var.run_e2e_tests_failure_topic_arn

  input_transformer {
    input_paths = {
      project_name = "$.detail.project-name"
      pipeline     = "$.detail.additional-information.pipeline"
      account      = "$.account"
      time         = "$.time"
      rspec_output = "$.detail.additional-information.rspec-output"
    }
    input_template = <<EOF
{
  "version": "1.0",
  "source": "custom",
  "content": {
    "textType": "client-markdown",
    "title": ":octagonal_sign: FAILURE: <project_name>",
    "description": "End to end tests failed in pipeline <pipeline> at <time> in the ${var.account_name} account with the error\n```<rspec_output>```",
    "keywords": [
      "${var.account_name}",
      "<pipeline>",
      "run-end-to-end-tests"
    ],
    "nextSteps": [
      "https://eu-west-2.console.aws.amazon.com/codesuite/codepipeline/pipelines/<pipeline>/view?action=run-end-to-end-tests&region=eu-west-2&stage=deploy-to-ecs"
    ]
  }
}
EOF
  }

  dead_letter_config {
    arn = var.dead_letter_queue_arn
  }
}
