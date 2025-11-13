resource "aws_sqs_queue" "cribl_s3_events_dlq" {
  #checkov:skip=CKV_AWS_27:DLQ for main queue - doesn't need its own DLQ
  name                              = "${module.cribl_well_known.cribl_sqs_queue_name}-dlq"
  message_retention_seconds         = 1209600 # 14 days
  kms_master_key_id                 = aws_kms_key.cribl_sqs.arn
  kms_data_key_reuse_period_seconds = 300

  tags = {
    Name    = "${module.cribl_well_known.cribl_sqs_queue_name}-dlq"
    IsDLQ   = "true"
    Service = "cribl"
  }
}

resource "aws_sqs_queue" "cribl_s3_events" {
  name                              = module.cribl_well_known.cribl_sqs_queue_name
  visibility_timeout_seconds        = 600
  message_retention_seconds         = 345600 # 4 days
  kms_master_key_id                 = aws_kms_key.cribl_sqs.arn
  kms_data_key_reuse_period_seconds = 300

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.cribl_s3_events_dlq.arn
    maxReceiveCount     = 5
  })

  tags = {
    Name = module.cribl_well_known.cribl_sqs_queue_name
  }
}

data "aws_iam_policy_document" "cribl_sqs_policy" {
  # Allow S3 to send messages to the queue from all accounts
  statement {
    sid    = "AllowS3ToSendMessages"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = [
      "sqs:SendMessage"
    ]
    resources = [aws_sqs_queue.cribl_s3_events.arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = var.aws_account_sources
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:s3:*:*:*"]
    }
  }
}

resource "aws_sqs_queue_policy" "cribl_sqs_policy" {
  queue_url = aws_sqs_queue.cribl_s3_events.id
  policy    = data.aws_iam_policy_document.cribl_sqs_policy.json
}
