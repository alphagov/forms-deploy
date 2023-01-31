resource "aws_sqs_queue" "sqs" {
  name                        = "sqs-${var.env_name}"
  visibility_timeout_seconds  = 90
  redrive_policy             = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.sqs_deadletter.arn}\",\"maxReceiveCount\":1}"
}

resource "aws_sqs_queue" "sqs_deadletter" {
  name = "sqs-deadletter-${var.env_name}"
}

data "aws_iam_policy_document" "queue_policy" {

  statement {
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.sqs.arn]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [module.logs_bucket.arn]
    }
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = module.logs_bucket.name
  queue {
    queue_arn     = aws_sqs_queue.sqs.arn
    events        = ["s3:ObjectCreated:*"]
  }
}

data "aws_iam_policy_document" "sqs_combined" {
  source_policy_documents = [
    data.aws_iam_policy_document.queue_policy.json,
    module.s3_log_shipping.sqs_policy
  ]
}

resource "aws_sqs_queue_policy" "queue_policy" {
  queue_url = aws_sqs_queue.sqs.id
  policy    = data.aws_iam_policy_document.sqs_combined.json
}
