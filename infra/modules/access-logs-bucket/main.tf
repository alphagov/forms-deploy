resource "aws_s3_bucket" "access_logs" {
  #checkov:skip=CKV_AWS_18:Access logs buckets themselves don't need access logging (infinite recursion)
  #checkov:skip=CKV_AWS_19:Bucket encrypted with AES256 using separate resource below
  #checkov:skip=CKV_AWS_144:No need for cross-region replication for access logs
  #checkov:skip=CKV_AWS_145:S3-SSE mode using AES256 is sufficient for access logs.
  #checkov:skip=CKV2_AWS_6:Access logs buckets have public access blocked via separate resource
  #checkov:skip=CKV2_AWS_61:Lifecycle rules configured separately below
  #checkov:skip=CKV2_AWS_62:Event notifications are not needed for access logs at this time

  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "access_logs_owner" {
  #checkov:skip=CKV2_AWS_65:BucketOwnerPreferred is required for Cribl to access files via cross-account access
  bucket = aws_s3_bucket.access_logs.id

  rule {
    object_ownership = var.send_access_logs_to_cyber ? "BucketOwnerPreferred" : "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "access_logs_policy" {
  statement {
    sid    = "S3ServerAccessLogsPolicy"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    actions = [
      "s3:PutObject",
    ]
    resources = ["${aws_s3_bucket.access_logs.arn}/*"]
  }
}

module "cyber_s3_log_shipping" {
  count = var.send_access_logs_to_cyber ? 1 : 0

  source  = "../cyber_s3_log_shipping"
  s3_name = aws_s3_bucket.access_logs.id
}

data "aws_iam_policy_document" "access_logs_combined_policy" {
  source_policy_documents = flatten([
    [data.aws_iam_policy_document.access_logs_policy.json],
    var.extra_bucket_policies,
    var.send_access_logs_to_cyber ? [module.cyber_s3_log_shipping[0].s3_policy] : [],
  ])
}

resource "aws_s3_bucket_policy" "access_logs_bucket_policy" {
  bucket = aws_s3_bucket.access_logs.id
  policy = data.aws_iam_policy_document.access_logs_combined_policy.json
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  rule {
    id     = "access_logs_lifecycle_processed"
    status = "Enabled"

    filter {
      tag {
        key   = "ProcessedByCribl"
        value = "Yes"
      }
    }

    expiration {
      days = 30
    }

    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }

  rule {
    id     = "access_logs_lifecycle_default"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    expiration {
      days = 180
    }

    noncurrent_version_expiration {
      noncurrent_days = 14
    }
  }
}
