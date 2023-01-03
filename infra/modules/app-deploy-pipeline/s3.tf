resource "aws_s3_bucket" "codepipeline" {
  #checkov:skip=CKV_AWS_18:Review S3 access logging in https://trello.com/c/qUzZfopX/416-review-s3-bucket-access-logging
  #checkov:skip=CKV_AWS_19:Bucket encrypted with AES256 using separate resource below
  #checkov:skip=CKV_AWS_21:Versioning is enabled via aws_s3_bucket_versioning below
  #checkov:skip=CKV_AWS_144:No need for cross-region replication
  #checkov:skip=CKV_AWS_145:S3-SSE mode using AES256 is sufficient.
  bucket = "codepipeline-artefacts-${var.app_name}-deploy"

  tags = {
    Name = "codepipeline-artefacts-${var.app_name}-deploy"
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.codepipeline.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "state" {
  bucket = aws_s3_bucket.codepipeline.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.codepipeline.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.codepipeline.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

