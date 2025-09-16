variable "name" {
  type = string
}

variable "extra_bucket_policies" {
  type        = list(string)
  description = "extra bucket policies to apply to this bucket. List of json policies"
  default     = []
}

variable "access_logging_enabled" {
  type        = bool
  description = "Whether S3 bucket access logging should be enabled"
  default     = false
  nullable    = false
}


resource "aws_s3_bucket" "this" {
  #checkov:skip=CKV_AWS_19:Bucket encrypted with AES256 using separate resource below
  #checkov:skip=CKV_AWS_21:Versioning is enabled via aws_s3_bucket_versioning below
  #checkov:skip=CKV_AWS_144:No need for cross-region replication
  #checkov:skip=CKV_AWS_145:S3-SSE mode using AES256 is sufficient.
  #checkov:skip=CKV_AWS_145:S3-SSE mode using AES256 is sufficient.
  #checkov:skip=CKV2_AWS_61:Lifecycle rules are not needed at this time
  #checkov:skip=CKV2_AWS_62:Notification are not needed at this time
  #checkov:skip=CKV2_AWS_6:Ensure that S3 bucket has a Public Access block

  bucket = var.name
  tags = {
    Name = var.name
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id
  #checkov:skip=CKV_AWS_55:Ensure S3 bucket has ignore public ACLs enabled
  #checkov:skip=CKV_AWS_54:Ensure S3 bucket has block public policy enabled
  #checkov:skip=CKV_AWS_53:Ensure S3 bucket has block public ACLS enabled
  #checkov:skip=CKV_AWS_56:Ensure S3 bucket has 'restrict_public_bucket' enabled
  #checkov:skip=CKV2_AWS_6:Ensure that S3 bucket has a Public Access block
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  #checkov:skip=CKV2_AWS_67:Not using CMK so CMK rotation not applicable.
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_iam_policy_document" "allow_public_access" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    sid       = "allow_public_access"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }
}

data "aws_iam_policy_document" "s3_combined_policy" {
  source_policy_documents = flatten([
    data.aws_iam_policy_document.allow_public_access.json,
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

resource "aws_s3_bucket_website_configuration" "bucket_website_configuration" {
  bucket = aws_s3_bucket.this.id
  index_document {
    suffix = "index.html"
  }
}

output "name" {
  value = aws_s3_bucket.this.id
}

output "arn" {
  value = aws_s3_bucket.this.arn
}

output "website_url" {
  value = aws_s3_bucket_website_configuration.bucket_website_configuration.website_endpoint
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
  bucket = "${var.name}-access-logs"

  tags = {
    Name = "${var.name}-access-logs"
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
  count  = var.access_logging_enabled ? 1 : 0
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

data "aws_iam_policy_document" "access_logs_combined_policy" {
  count = var.access_logging_enabled ? 1 : 0
  source_policy_documents = [
    data.aws_iam_policy_document.access_logs_policy[0].json
  ]
}

resource "aws_s3_bucket_policy" "access_logs_bucket_policy" {
  count  = var.access_logging_enabled ? 1 : 0
  bucket = aws_s3_bucket.access_logs[0].id
  policy = data.aws_iam_policy_document.access_logs_combined_policy[0].json
}

resource "aws_s3_bucket_logging" "this" {
  count  = var.access_logging_enabled ? 1 : 0
  bucket = aws_s3_bucket.this.id

  target_bucket = aws_s3_bucket.access_logs[0].id
  target_prefix = "s3-access-logs"

  target_object_key_format {
    partitioned_prefix {
      partition_date_source = "DeliveryTime"
    }
  }
}

