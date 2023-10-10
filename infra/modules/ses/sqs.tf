resource "aws_sqs_queue" "ses_bounces_and_complaints_queue" {
  #checkov:skip=CKV_AWS_27:ignoring while testing.
  name                      = "ses_bounces_and_complaints_queue"
  message_retention_seconds = 1209600
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.ses_dead_letter_queue.arn}\",\"maxReceiveCount\":4}"
}

resource "aws_sqs_queue" "ses_dead_letter_queue" {
  #checkov:skip=CKV_AWS_27:ignoring while testing.
  name = "ses_dead_letter_queue"
}

resource "aws_sns_topic" "ses_bounces_and_complaints_topic" {
  #checkov:skip=CKV_AWS_26:ignoring while testing.
  name = "ses_bounces_and_complaints_topic"
}

resource "aws_sns_topic_subscription" "ses_bounces_and_complaints_subscription" {
  topic_arn = aws_sns_topic.ses_bounces_and_complaints_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.ses_bounces_and_complaints_queue.arn
}

data "aws_iam_policy_document" "ses_bounces_and_complaints_queue_iam_policy" {
  policy_id = "SESBouncesComplatintsQueueTopic"
  statement {
    sid       = "SESBouncesComplaintsQueueTopic"
    effect    = "Allow"
    actions   = ["SQS:SendMessage"]
    resources = ["${aws_sqs_queue.ses_bounces_and_complaints_queue.arn}"]
    condition {
      test     = "ArnEquals"
      values   = ["${aws_sns_topic.ses_bounces_and_complaints_topic.arn}"]
      variable = "aws:SourceArn"
    }
  }
}

resource "aws_sqs_queue_policy" "ses_bounces_and_complaints_queue_policy" {
  queue_url = aws_sqs_queue.ses_bounces_and_complaints_queue.id
  policy    = data.aws_iam_policy_document.ses_bounces_and_complaints_queue_iam_policy.json
}
