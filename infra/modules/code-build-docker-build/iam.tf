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
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetAuthorizationToken",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions = ["ssm:GetParameter", "ssm:GetParameters"]
    resources = [
      "arn:aws:ssm:eu-west-2:${local.aws_account_id}:parameter${var.docker_username_parameter_path}",
      "arn:aws:ssm:eu-west-2:${local.aws_account_id}:parameter${var.docker_password_parameter_path}",
    ]
    effect = "Allow"
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

