locals {
  deploy_account_id = "711966560482"

  account_ids = {
    "dev"           = "498160065950"
    "staging"       = "972536609845"
    "production"    = "443944947292"
    "user-research" = "619109835131"
  }
}

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

