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
resource "aws_s3_bucket" "access_logs" {
  #checkov:skip=CKV_AWS_18:Access logs buckets themselves don't need access logging (infinite recursion)
  #checkov:skip=CKV_AWS_19:Bucket encrypted with AES256 using separate resource below
  #checkov:skip=CKV_AWS_21:Versioning is enabled via aws_s3_bucket_versioning below
  #checkov:skip=CKV_AWS_144:No need for cross-region replication for access logs
  #checkov:skip=CKV_AWS_145:S3-SSE mode using AES256 is sufficient for access logs.
  #checkov:skip=CKV2_AWS_6:Access logs buckets have public access blocked via separate resource
  #checkov:skip=CKV2_AWS_61:Lifecycle rules are not needed for access logs at this time
  #checkov:skip=CKV2_AWS_62:Event notifications are not needed for access logs at this time
  count  = var.access_logging_enabled ? 1 : 0
  bucket = "${var.bucket_name}-access-logs"

  tags = {
    Name = "${var.bucket_name}-access-logs"
  }
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  count  = var.access_logging_enabled ? 1 : 0
  bucket = aws_s3_bucket.access_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "access_logs" {
  count  = var.access_logging_enabled ? 1 : 0
  bucket = aws_s3_bucket.access_logs[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  count  = var.access_logging_enabled ? 1 : 0
  bucket = aws_s3_bucket.access_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "access_logs_owner" {
  count  = var.access_logging_enabled && !var.send_access_logs_to_cyber ? 1 : 0
  bucket = aws_s3_bucket.access_logs[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }

}

data "aws_iam_policy_document" "access_logs_policy" {
  count = var.access_logging_enabled ? 1 : 0

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
    resources = ["${aws_s3_bucket.access_logs[0].arn}/*"]
  }
}

module "s3_log_shipping_access_logs" {
  count = var.access_logging_enabled && var.send_access_logs_to_cyber ? 1 : 0

  # Double slash after .git in the module source below is required
  # https://developer.hashicorp.com/terraform/language/modules/sources#modules-in-package-sub-directories
  source                   = "git::https://github.com/alphagov/cyber-security-shared-terraform-modules.git//s3/s3_log_shipping?ref=6fecf620f987ba6456ea6d7307aed7d83f077c32"
  s3_processor_lambda_role = "arn:aws:iam::885513274347:role/csls_prodpython/csls_process_s3_logs_lambda_prodpython"
  s3_name                  = aws_s3_bucket.access_logs[0].id
}

data "aws_iam_policy_document" "access_logs_combined_policy" {
  count = var.access_logging_enabled ? 1 : 0
  source_policy_documents = flatten([
    [data.aws_iam_policy_document.access_logs_policy[0].json],
    var.send_access_logs_to_cyber ? [module.s3_log_shipping_access_logs[0].s3_policy] : []
  ])
}

resource "aws_s3_bucket_policy" "access_logs_bucket_policy" {
  count  = var.access_logging_enabled ? 1 : 0
  bucket = aws_s3_bucket.access_logs[0].id
  policy = data.aws_iam_policy_document.access_logs_combined_policy[0].json
}

resource "aws_s3_bucket_logging" "state" {
  count  = var.access_logging_enabled ? 1 : 0
  bucket = aws_s3_bucket.state.id

  target_bucket = aws_s3_bucket.access_logs[0].id
  target_prefix = "s3-access-logs"

  target_object_key_format {
    partitioned_prefix {
      partition_date_source = "DeliveryTime"
    }
  }
}

resource "aws_s3_bucket_notification" "access_logs_bucket_notification" {
  count = var.access_logging_enabled && var.send_access_logs_to_cyber ? 1 : 0

  bucket = aws_s3_bucket.access_logs[0].id
  queue {
    queue_arn = "arn:aws:sqs:eu-west-2:885513274347:cyber-security-s3-to-splunk-prodpython"
    events    = ["s3:ObjectCreated:*"]
  }
}
