# CodeBuild IAM Role and Policies

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild" {
  name               = "codebuild-drift-check-${var.deployment_name}"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}

data "aws_iam_policy_document" "codebuild" {
  # CloudWatch Logs permissions
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.drift_check.arn}:*"]
    effect    = "Allow"
  }

  # SSM Parameter Store permissions - read only
  statement {
    actions = [
      "ssm:DescribeParameters",
    ]
    resources = ["*"]
    effect    = "Allow"
  }

  statement {
    actions = [
      "ssm:GetParameter",
    ]
    resources = [
      "arn:aws:ssm:${local.aws_region}:${local.aws_account_id}:parameter/terraform/last_applied/${var.deployment_name}/*"
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "codebuild" {
  name   = "codebuild-drift-check-${var.deployment_name}"
  path   = "/"
  policy = data.aws_iam_policy_document.codebuild.json
}

resource "aws_iam_role_policy_attachment" "codebuild" {
  policy_arn = aws_iam_policy.codebuild.arn
  role       = aws_iam_role.codebuild.id
}

# EventBridge IAM Role and Policies

data "aws_iam_policy_document" "eventbridge_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eventbridge" {
  name               = "eventbridge-drift-check-${var.deployment_name}"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_assume_role.json
}

data "aws_iam_policy_document" "eventbridge" {
  statement {
    actions = [
      "codebuild:StartBuild",
    ]
    resources = [
      aws_codebuild_project.drift_check.arn
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "eventbridge" {
  name   = "eventbridge-drift-check-${var.deployment_name}"
  path   = "/"
  policy = data.aws_iam_policy_document.eventbridge.json
}

resource "aws_iam_role_policy_attachment" "eventbridge" {
  policy_arn = aws_iam_policy.eventbridge.arn
  role       = aws_iam_role.eventbridge.id
}
