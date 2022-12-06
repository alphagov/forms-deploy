variable "env_name" {
  type        = string
  description = "The name of the environment to be used in resource names."
  validation {
    condition     = contains(["dev", "staging", "prod"], var.env_name)
    error_message = "Valid values for env_name are: dev, staging, prod"
  }
}

variable "codebuild_terraform_arns" {
  type        = list(string)
  description = "The role arns for codebuild applying terraform"
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.codebuild_terraform_arns
    }
  }
}

resource "aws_iam_role" "deployer" {
  name               = "deployer-${var.env_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "admin" { //TODO: lock this down when its working
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.deployer.id
}

