terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.11"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
  }
}

# IAM trust for Lambda (local to this submodule)
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Package the shared handler from parent module path
data "archive_file" "zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/handler.py"
  output_path = "${path.module}/.build/${var.name}.zip"
}

# Lambda role
resource "aws_iam_role" "this" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

data "aws_iam_policy_document" "inline" {
  statement {
    sid       = "EcsUpdate"
    actions   = ["ecs:UpdateService"]
    resources = [var.service_arn]
  }
  statement {
    sid       = "EcsDescribe"
    actions   = ["ecs:DescribeServices", "ecs:DescribeClusters"]
    resources = ["*"]
  }
  statement {
    sid       = "Logs"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "this" {
  name   = "${var.name}-inline"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.inline.json
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = var.log_retention_days
}

resource "aws_lambda_function" "this" {
  function_name    = var.name
  role             = aws_iam_role.this.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256

  environment {
    variables = {
      TARGET_CLUSTER_ARN = var.cluster_arn
      TARGET_SERVICE_ARN = var.service_arn
      WATCHED_SECRETS    = jsonencode(var.secret_arns)
    }
  }
}

# One rule per redeploy function on the default bus in this account
resource "aws_cloudwatch_event_rule" "this" {
  name = var.name
  event_pattern = jsonencode({
    source      = ["aws.secretsmanager"],
    detail-type = ["AWS API Call via CloudTrail"],
    detail = {
      eventSource       = ["secretsmanager.amazonaws.com"],
      eventName         = ["PutSecretValue", "UpdateSecretVersionStage", "RotateSecret"],
      requestParameters = { secretId = var.secret_arns }
    }
  })
}

resource "aws_cloudwatch_event_target" "this" {
  rule      = aws_cloudwatch_event_rule.this.name
  target_id = "lambda"
  arn       = aws_lambda_function.this.arn
}

resource "aws_lambda_permission" "allow_events" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}

output "lambda_name" {
  value       = aws_lambda_function.this.function_name
  description = "Lambda name"
}

output "lambda_arn" {
  value       = aws_lambda_function.this.arn
  description = "Lambda ARN"
}

output "rule_name" {
  value       = aws_cloudwatch_event_rule.this.name
  description = "EventBridge rule name"
}

output "rule_arn" {
  value       = aws_cloudwatch_event_rule.this.arn
  description = "EventBridge rule ARN"
}
