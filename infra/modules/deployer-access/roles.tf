data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "codepipeline.amazonaws.com",
        "codebuild.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "deployer" {
  name               = "deployer-${var.environment_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

