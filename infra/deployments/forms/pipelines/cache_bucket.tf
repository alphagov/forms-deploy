module "codebuild_cache_bucket" {
  source = "../../../modules/secure-bucket"

  name = "pipeline-govuk-forms-codebuild-cache-${var.environment_name}"
}
moved {
  from = module.provider_cache_bucket
  to   = module.codebuild_cache_bucket
}


locals {
  cache_namespaces = {
    terraform_providers = {
      name        = "apply-terraform-${var.environment_name}"
      keep_newest = 10
    }
    e2e_tests = {
      name        = "e2e-tests-${var.environment_name}"
      keep_newest = 10
    }
  }
}

# Lambda function for cache cleanup
resource "aws_lambda_function" "cache_cleanup" {
  #checkov:skip=CKV_AWS_50:X-Ray tracing not needed for simple daily cleanup function
  #checkov:skip=CKV_AWS_117:VPC not needed as S3 is accessible without VPC
  #checkov:skip=CKV_AWS_116:DLQ not needed for simple scheduled cleanup that can retry next day
  #checkov:skip=CKV_AWS_173:Environment variables contain non-sensitive configuration only
  #checkov:skip=CKV_AWS_272:Code signing not required for internal cleanup function
  #checkov:skip=CKV_AWS_115:Reserved concurrent executions not needed for single daily execution
  function_name = "codebuild-cache-cleanup-${var.environment_name}"
  runtime       = "python3.12"
  handler       = "cleanup.handler"
  role          = aws_iam_role.cache_cleanup_lambda.arn
  # Timeout: 5 minutes is sufficient. With keep_newest=10, max ~20 objects to analyze per namespace.
  # delete_objects handles 1000 objects per batch in ~1 second. Even with thousands to delete initially,
  # this completes in well under 5 minutes.
  timeout = 300

  filename         = data.archive_file.cache_cleanup_lambda.output_path
  source_code_hash = data.archive_file.cache_cleanup_lambda.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME = module.codebuild_cache_bucket.name
      NAMESPACES  = jsonencode(values(local.cache_namespaces))
    }
  }

  depends_on = [aws_cloudwatch_log_group.cache_cleanup_log_group]
}

# CloudWatch log group for Lambda
resource "aws_cloudwatch_log_group" "cache_cleanup_log_group" {
  #checkov:skip=CKV_AWS_338:We're happy with 30 days retention for now
  #checkov:skip=CKV_AWS_158:Amazon managed SSE is sufficient.
  name              = "/aws/lambda/codebuild-cache-cleanup-${var.environment_name}"
  retention_in_days = 30
}

# Package Lambda source code
data "archive_file" "cache_cleanup_lambda" {
  type        = "zip"
  output_path = "${path.module}/s3-cache-cleanup/lambda/cache_cleanup.zip"

  source {
    content  = file("${path.module}/s3-cache-cleanup/lambda/cleanup.py")
    filename = "cleanup.py"
  }
}

# IAM role for Lambda
resource "aws_iam_role" "cache_cleanup_lambda" {
  name = "codebuild-cache-cleanup-lambda-${var.environment_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# IAM policy for S3 access
resource "aws_iam_role_policy" "cache_cleanup_s3" {
  role = aws_iam_role.cache_cleanup_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:ListBucket",
        "s3:DeleteObject"
      ]
      Resource = [
        module.codebuild_cache_bucket.arn,
        "${module.codebuild_cache_bucket.arn}/*"
      ]
    }]
  })
}

# CloudWatch Logs policy
resource "aws_iam_role_policy_attachment" "cache_cleanup_logs" {
  role       = aws_iam_role.cache_cleanup_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# EventBridge rule to trigger daily
resource "aws_cloudwatch_event_rule" "cache_cleanup_schedule" {
  name                = "codebuild-cache-cleanup-${var.environment_name}"
  description         = "Trigger cache cleanup Lambda daily"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "cache_cleanup_lambda" {
  #checkov:skip=CKV2_FORMS_AWS_6:DLQ not needed for simple scheduled cleanup that can retry next day
  rule      = aws_cloudwatch_event_rule.cache_cleanup_schedule.name
  target_id = "cache-cleanup-lambda"
  arn       = aws_lambda_function.cache_cleanup.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cache_cleanup.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cache_cleanup_schedule.arn
}

# Basic lifecycle rules for multipart uploads and noncurrent versions
resource "aws_s3_bucket_lifecycle_configuration" "codebuild_cache_basic" {
  bucket = module.codebuild_cache_bucket.name

  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"
    filter {}
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"
    filter {}
    noncurrent_version_expiration {
      newer_noncurrent_versions = 2
      noncurrent_days           = 14
    }
  }
}
