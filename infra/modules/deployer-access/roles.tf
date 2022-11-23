variable "env_name" {
  type        = string
  description = "The name of the environment to be used in resource names."
  validation {
    condition     = contains(["dev", "staging", "prod"], var.env_name)
    error_message = "Valid values for env_name are: dev, staging, prod"
  }
}

variable "codebuild_terraform_arn" {
  type        = string
  description = "The role arn for codebuild applying terraform"
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.account_id}:role/dan.worth-admin",
        var.codebuild_terraform_arn
      ]
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

