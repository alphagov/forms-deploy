resource "aws_s3_bucket" "this" {
  #checkov:skip=CKV_AWS_19:Bucket encrypted with AES256 using separate resource below
  #checkov:skip=CKV_AWS_21:Versioning is enabled via aws_s3_bucket_versioning below
  #checkov:skip=CKV_AWS_144:No need for cross-region replication
  #checkov:skip=CKV_AWS_145:S3-SSE mode using AES256 is sufficient.
  #checkov:skip=CKV_AWS_145:S3-SSE mode using AES256 is sufficient.
  #checkov:skip=CKV2_AWS_61:Lifecycle rules are not needed at this time
  #checkov:skip=CKV2_AWS_62:Notification are not needed at this time

  bucket = var.name

  tags = {
    Name = var.name
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  #checkov:skip=CKV2_AWS_67:Not using CMK so CMK rotation not applicable.
  count  = var.AES256_encryption_configuration ? 1 : 0
  bucket = aws_s3_bucket.this.id

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
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
  }
}

data "aws_iam_policy_document" "s3_combined_policy" {
  source_policy_documents = flatten([
    data.aws_iam_policy_document.https_only.json,
  var.extra_bucket_policies])
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.s3_combined_policy.json
}

resource "aws_s3_bucket_ownership_controls" "owner" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# S3 Access Logging Configuration
module "access_logs_bucket" {
  count = var.access_logging_enabled ? 1 : 0

  source = "../access-logs-bucket"

  bucket_name = "${var.name}-access-logs"

  send_access_logs_to_cyber = var.send_access_logs_to_cyber
}

resource "aws_s3_bucket_logging" "this" {
  count  = var.access_logging_enabled ? 1 : 0
  bucket = aws_s3_bucket.this.id

  target_bucket = module.access_logs_bucket[0].bucket_id
  target_prefix = "s3-access-logs/"

  target_object_key_format {
    partitioned_prefix {
      partition_date_source = "DeliveryTime"
    }
  }
}
