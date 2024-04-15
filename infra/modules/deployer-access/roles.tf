variable "env_name" {
  type        = string
  description = "The name of the environment to be used in resource names."
  validation {
    condition     = contains(["user-research", "dev", "staging", "production"], var.env_name)
    error_message = "Valid values for env_name are: user-research, dev, staging, production"
  }
}

variable "hosted_zone_id" {
  description = "The ID of the AWS hosted zone in the account, to which DNS records will be added"
  type        = string
  nullable    = false
}

variable "codestar_connection_arn" {
  type        = string
  description = "ARN of the CodeStar connection in the account"
}

locals {
  deploy_account_id = "711966560482"

  account_ids = {
    "dev"           = "498160065950"
    "staging"       = "972536609845"
    "production"    = "443944947292"
    "user-research" = "619109835131"
  }

  deploy_account_terraform_apply = [
    "arn:aws:iam::${local.deploy_account_id}:role/codebuild-apply-terraform-${var.env_name}"
  ]

  deployer_roles_per_env = {
    "user-research" = local.deploy_account_terraform_apply,
    "dev"           = local.deploy_account_terraform_apply,
    "staging"       = local.deploy_account_terraform_apply,
    "production"    = local.deploy_account_terraform_apply
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = lookup(local.deployer_roles_per_env, var.env_name)
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"

      values = [var.env_name]
    }
  }

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
  name               = "deployer-${var.env_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

