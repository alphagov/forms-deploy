resource "aws_cloudwatch_event_rule" "pipeline_failure" {
  name        = "${var.account_name}-account-pipeline-failure-events"
  description = "Send pipeline failure messages to Slack"
  event_pattern = jsonencode({
    source      = ["aws.codepipeline", "uk.gov.service.forms"],
    detail-type = ["CodePipeline Pipeline Execution State Change"]
    account     = [var.account_id]
    detail = {
      state = ["FAILED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "send_pipeline_failure_to_slack" {
  target_id = "send-to-slack"
  rule      = aws_cloudwatch_event_rule.pipeline_failure.name
  arn       = var.pipeline_failure_topic_arn

  input_transformer {
    input_paths    = local.chatbot_message_input_paths
    input_template = <<EOF
{
    "version": "1.0",
    "source": "custom",
    "content": {
        "textType": "client-markdown",
        "title": ":octagonal_sign: FAILURE: <pipeline>",
        "description": "Pipeline <pipeline> failed at <time> in the ${var.account_name} account",
        "keywords": [
          "${var.account_name}",
          "<pipeline>"
        ],
        "nextSteps": [
            "https://eu-west-2.console.aws.amazon.com/codesuite/codepipeline/pipelines/<pipeline>/view?region=eu-west-2"
        ]
    }
}
EOF
  }

  dead_letter_config {
    arn = var.dead_letter_queue_arn
  }
}
