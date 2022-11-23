data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "codebuild" {
  statement {
    actions   = ["logs:*"]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions = ["s3:*"]
    resources = [
      "${var.artifact_store_arn}/*",
      "${var.artifact_store_arn}"
    ]
    effect = "Allow"
  }
  statement {
    actions   = ["sts:AssumeRole"]
    effect    = "Allow"
    resources = [var.deployer_role_arn]
  }
}

resource "aws_iam_policy" "codebuild" {
  name   = "codebuild-${var.project_name}"
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
  name = "codebuild-${var.project_name}"

  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}

resource "aws_iam_role_policy_attachment" "codebuild" {
  policy_arn = aws_iam_policy.codebuild.arn
  role       = aws_iam_role.codebuild.id
}

