resource "aws_sqs_queue" "event_bridge_dlq" {
  #checkov:skip=CKV_AWS_27: We're OK with dead letters from EventBridge not being encrypted
  name   = "eventbridge-dead-letter-queue"
  policy = data.aws_iam_policy_document.allows_eventbridge_to_deliver_to_sqs.json
}

data "aws_iam_policy_document" "allows_eventbridge_to_deliver_to_sqs" {
  statement {
    sid       = "AllowEventBridgeToDeliver"
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = ["arn:aws:sqs:eu-west-2:${var.deploy_account_id}:eventbridge-dead-letter-queue"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}
