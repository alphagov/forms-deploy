resource "aws_s3_bucket" "state" {
  #checkov:skip=CKV_AWS_19:Bucket encrypted with AES256 using separate resource below
  #checkov:skip=CKV_AWS_21:Versioning is enabled via aws_s3_bucket_versioning below
  #checkov:skip=CKV_AWS_144:No need for cross-region replication
  #checkov:skip=CKV_AWS_145:S3-SSE mode using AES256 is sufficient.
  #checkov:skip=CKV2_AWS_61:Lifecycle rules are not needed at this time
  #checkov:skip=CKV2_AWS_62:Notification are not needed at this time
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "owner" {
  count  = !var.send_access_logs_to_cyber ? 1 : 0
  bucket = aws_s3_bucket.state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = var.bucket_name

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  #checkov:skip=CKV2_AWS_67:Not using CMK so CMK rotation not applicable.
  bucket = var.bucket_name

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_iam_policy_document" "https_only" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    sid     = "https_only"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.state.arn,
      "${aws_s3_bucket.state.arn}/*"
    ]
    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.state.id
  policy = data.aws_iam_policy_document.https_only.json
}

# S3 Access Logging Configuration
module "access_logs_bucket" {
  count = var.access_logging_enabled ? 1 : 0

  source = "../access-logs-bucket"

  bucket_name               = "${var.bucket_name}-access-logs"
  send_access_logs_to_cyber = var.send_access_logs_to_cyber
}

moved {
  from = module.s3_log_shipping_access_logs[0]
  to   = module.access_logs_bucket[0].module.cyber_s3_log_shipping[0].module.s3_log_shipping
}

resource "aws_s3_bucket_logging" "state" {
  count  = var.access_logging_enabled ? 1 : 0
  bucket = aws_s3_bucket.state.id

  target_bucket = module.access_logs_bucket[0].bucket_id
  target_prefix = "s3-access-logs/"

  target_object_key_format {
    partitioned_prefix {
      partition_date_source = "DeliveryTime"
    }
  }
}

moved {
  from = aws_s3_bucket_notification.access_logs_bucket_notification[0]
  to   = module.access_logs_bucket[0].module.cyber_s3_log_shipping[0].aws_s3_bucket_notification.s3_bucket_notification
}

moved {
  from = aws_s3_bucket.access_logs[0]
  to   = module.access_logs_bucket[0].aws_s3_bucket.access_logs
}
moved {
  from = aws_s3_bucket_policy.access_logs_bucket_policy[0]
  to   = module.access_logs_bucket[0].aws_s3_bucket_policy.access_logs_bucket_policy
}
moved {
  from = aws_s3_bucket_public_access_block.access_logs[0]
  to   = module.access_logs_bucket[0].aws_s3_bucket_public_access_block.access_logs
}
moved {
  from = aws_s3_bucket_versioning.access_logs[0]
  to   = module.access_logs_bucket[0].aws_s3_bucket_versioning.access_logs
}
moved {
  from = aws_s3_bucket_ownership_controls.access_logs_owner[0]
  to   = module.access_logs_bucket[0].aws_s3_bucket_ownership_controls.access_logs_owner[0]
}
moved {
  from = aws_s3_bucket_server_side_encryption_configuration.access_logs[0]
  to   = module.access_logs_bucket[0].aws_s3_bucket_server_side_encryption_configuration.access_logs
}
