module "cribl_well_known" {
  source = "../well-known/cribl"
}

# IAM policy for Cribl role to access S3 bucket
data "aws_iam_policy_document" "cribl_s3_access" {
  statement {
    sid = "CriblS3Access"

    principals {
      type        = "AWS"
      identifiers = [module.cribl_well_known.cribl_role_arn]
    }

    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging"
    ]

    resources = [
      "arn:aws:s3:::${var.s3_name}",
      "arn:aws:s3:::${var.s3_name}/*",
    ]
  }
}

# S3 bucket notifications
resource "aws_s3_bucket_notification" "s3_bucket_notification" {
  bucket = var.s3_name

  # We can't push events to multiple SQS queues at once, so we conditionally choose
  # which queue to use based on the destination variable.
  queue {
    queue_arn = module.cribl_well_known.cribl_sqs_queue_arn
    events    = ["s3:ObjectCreated:*"]
  }
}
