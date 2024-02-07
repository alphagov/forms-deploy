data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "codepipeline" {
    statement {
        actions   = ["cloudwatch:*"]
        resources = ["arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/*"]
        effect    = "Allow"
    }
    statement {
        actions = ["codebuild:*"]
        resources = [
            module.docker_build.arn,
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
        actions   = ["codecommit:Get*", "codecommit:Describe*", "codecommit:GitPull"]
        resources = [var.github_connection_arn]
        effect    = "Allow"
    }
    statement {
        actions   = ["s3:*"]
        resources = ["${module.artifact_bucket.arn}/*"]
        effect    = "Allow"
    }
}

resource "aws_iam_policy" "codepipeline" {
    name   = "codepipline-${local.name_suffix}"
    path   = "/"
    policy = data.aws_iam_policy_document.codepipeline.json
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

resource "aws_iam_role" "codepipeline" {
    name = "codepipeline-${local.name_suffix}"

    assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
}

resource "aws_iam_role_policy_attachment" "codepipeline" {
    policy_arn = aws_iam_policy.codepipeline.arn
    role       = aws_iam_role.codepipeline.id
}
