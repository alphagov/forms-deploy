module "other_accounts" {
  source = "../all-accounts"
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.project_name}:*",
      "arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:codebuild/${var.project_name}:*"
    ]
    effect = "Allow"
  }
  statement {
    actions = [
      "codestar-connections:UseConnection",
      "codestar-connections:GetConnection",
      "codestar-connections:ListConnections"
    ]
    resources = [var.codestar_connection_arn]
    effect    = "Allow"
  }
  statement {
    actions   = ["codecommit:Get*", "codecommit:Describe*", "codecommit:GitPull"]
    resources = [var.codestar_connection_arn]
    effect    = "Allow"
  }
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "${var.artifact_store_arn}/*",
      var.artifact_store_arn
    ]
    effect = "Allow"
  }
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = [
      "arn:aws:ecr:eu-west-2:${data.aws_caller_identity.current.account_id}:repository/${var.image_name}",
      "arn:aws:ecr:eu-west-2:${data.aws_caller_identity.current.account_id}:repository/${var.image_name}/*"
    ]
    effect = "Allow"
  }
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions = ["ssm:GetParameter", "ssm:GetParameters"]
    resources = [
      "arn:aws:ssm:eu-west-2:${local.aws_account_id}:parameter/*"
    ]
    effect = "Allow"
  }
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    resources = [
      # this doesn't allow this role to assume all roles in these environments, only the roles specified in their trust policies
      "arn:aws:iam::${module.other_accounts.environment_accounts_id["staging"]}:role/*",
      "arn:aws:iam::${module.other_accounts.environment_accounts_id["development"]}:role/*",
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
