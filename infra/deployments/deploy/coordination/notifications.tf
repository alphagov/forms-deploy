locals {
  # We have configured AWS ChatBot for sending messages to Slack.
  # AWS ChatBot does not have an API we can use in Terraform, so we
  # configured it by hand in the one place and hardcoded the SNS topic here.
  chatbot_deployments_channel_sns_topic = "arn:aws:sns:eu-west-2:711966560482:CodeStarNotifications-govuk-forms-deployments-c383f287ab987f0b12d32e4533a145b1c918167d"
  chatbot_alerts_channel_sns_topic      = "arn:aws:sns:eu-west-2:711966560482:CodeStarNotifications-govuk-forms-alert-b7410628fe547543676d5dc062cf342caba48bcd"

  chatbot_message_input_paths = {
    pipeline = "$.detail.pipeline"
    account  = "$.account"
    time     = "$.time"
  }
}

resource "aws_cloudwatch_event_rule" "pipeline_completion" {
  name        = "pipeline-success-events"
  description = "Send pipeline success messages to Slack"
  event_pattern = jsonencode({
    source      = ["aws.codepipeline", "uk.gov.service.forms"],
    detail-type = ["CodePipeline Pipeline Execution State Change"]
    detail = {
      state = ["SUCCEEDED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "send_pipeline_completion_to_slack" {
  target_id = "send-to-slack"
  rule      = aws_cloudwatch_event_rule.pipeline_completion.name
  arn       = local.chatbot_deployments_channel_sns_topic

  input_transformer {
    input_paths    = local.chatbot_message_input_paths
    input_template = <<EOF
{
    "version": "1.0",
    "source": "custom",
    "content": {
        "textType": "client-markdown",
        "title": ":tada: SUCCESS: <pipeline>",
        "description": "Pipeline <pipeline> completed at <time>",
        "nextSteps": [
            "https://eu-west-2.console.aws.amazon.com/codesuite/codepipeline/pipelines/<pipeline>/view?region=eu-west-2"
        ]
    }
}
EOF
  }

  dead_letter_config {
    arn = aws_sqs_queue.event_bridge_dlq.arn
  }
}

resource "aws_cloudwatch_event_rule" "pipeline_failure" {
  name        = "pipeline-failure-events"
  description = "Send pipeline failure messages to Slack"
  event_pattern = jsonencode({
    source      = ["aws.codepipeline", "uk.gov.service.forms"],
    detail-type = ["CodePipeline Pipeline Execution State Change"]
    detail = {
      state = ["FAILED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "send_pipeline_failure_to_slack" {
  target_id = "send-to-slack"
  rule      = aws_cloudwatch_event_rule.pipeline_failure.name
  arn       = local.chatbot_alerts_channel_sns_topic

  input_transformer {
    input_paths    = local.chatbot_message_input_paths
    input_template = <<EOF
        {
            "version": "1.0",
            "source": "custom",
            "content": {
                "textType": "client-markdown",
                "title": ":octagonal_sign: FAILURE: <pipeline>",
                "description": "Pipeline <pipeline> failed at <time>",
                "nextSteps": [
                    "https://eu-west-2.console.aws.amazon.com/codesuite/codepipeline/pipelines/<pipeline>/view?region=eu-west-2"
                ]
            }
        }
        EOF
  }

  dead_letter_config {
    arn = aws_sqs_queue.event_bridge_dlq.arn
  }
}