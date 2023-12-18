variable "name" {
  type = string
}

variable "extra_bucket_policies" {
  type        = list(string)
  description = "extra bucket policies to apply to this bucket. List of json policies"
  default     = []
}

resource "aws_s3_bucket" "this" {
  #checkov:skip=CKV_AWS_18:Review S3 access logging in https://trello.com/c/qUzZfopX/416-review-s3-bucket-access-logging
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
    resources = ["arn:aws:s3:::govuk-forms-dev-error-page/*"]
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
