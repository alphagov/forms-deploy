data "aws_iam_policy_document" "codebuild" {
  statement {
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup"
    ]
    resources = ["${aws_cloudwatch_log_group.log_group.arn}:*"]
    effect    = "Allow"
  }
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = [
      "arn:aws:ecr:eu-west-2:${var.deploy_account_id}:repository/end-to-end-tests",
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "codebuild" {
  name   = "codebuild-${var.test_name}-${var.environment}"
  path   = "/"
  policy = data.aws_iam_policy_document.codebuild.json
}

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "codebuild.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "codebuild" {
  name = "codebuild-${var.test_name}-${var.environment}"

  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}

resource "aws_iam_role_policy_attachment" "codebuild" {
  policy_arn = aws_iam_policy.codebuild.arn
  role       = aws_iam_role.codebuild.id
}

