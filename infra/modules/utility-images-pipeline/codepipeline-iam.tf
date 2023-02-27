data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "main_permissions" {
  statement {
    actions   = ["cloudwatch:*"]
    resources = ["arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/*"]
    effect    = "Allow"
  }
  statement {
    actions = ["codebuild:*"]
    resources = [
      module.docker_build_end_to_end_tests.arn
    ]
    effect = "Allow"
  }
  statement {
    actions = [
      "codestar-connections:UseConnection",
      "codestar-connections:GetConnection",
      "codestar-connections:ListConnections"
    ]
    resources = [var.github_connection_arn]
    effect    = "Allow"
  }
  statement {
    actions   = ["codecommit:Get*", "codecommit:Describe*"]
    resources = [var.github_connection_arn]
    effect    = "Allow"
  }

  statement {
    actions   = ["s3:*"]
    resources = ["${module.artifact_bucket.arn}/*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "main_permissions" {
  name        = "codepipline-utility-images"
  description = "Used by codepipeline to build docker images used by other code pipelines"
  path        = "/"
  policy      = data.aws_iam_policy_document.main_permissions.json
}

data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "codepipeline.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "this" {
  name        = "codepipeline-utility-images"
  description = "Used by codepipeline to build docker images used by other code pipelines"

  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = aws_iam_policy.main_permissions.arn
  role       = aws_iam_role.this.id
}
