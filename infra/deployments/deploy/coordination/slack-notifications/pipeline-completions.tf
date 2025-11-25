resource "aws_cloudwatch_event_rule" "pipeline_completion" {
  name        = "${var.account_name}-account-pipeline-completion-events"
  description = "Send pipeline completion messages to Slack"
  event_pattern = jsonencode({
    source      = ["aws.codepipeline", "uk.gov.service.forms"],
    detail-type = ["CodePipeline Pipeline Execution State Change"]
    account     = [var.account_id]
    detail = {
      state = ["SUCCEEDED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "send_pipeline_completion_to_slack" {
  target_id = "send-to-slack"
  rule      = aws_cloudwatch_event_rule.pipeline_completion.name
  arn       = var.pipeline_completion_topic_arn

  input_transformer {
    input_paths    = local.chatbot_message_input_paths
    input_template = <<EOF
{
    "version": "1.0",
    "source": "custom",
    "content": {
        "textType": "client-markdown",
        "title": ":tada: SUCCESS: <pipeline>",
        "description": "Pipeline <pipeline> completed at <time> in the ${var.account_name} account",
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
