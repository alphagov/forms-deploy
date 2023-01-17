variable "env_name" {
  type        = string
  description = "The name of the environment to be used in resource names."
  validation {
    condition     = contains(["user-research", "dev", "staging", "production"], var.env_name)
    error_message = "Valid values for env_name are: user-research, dev, staging, production"
  }
}

locals {
  deploy_account_id = "711966560482"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.deploy_account_id}:role/codebuild-forms-api-deploy-${var.env_name}",
        "arn:aws:iam::${local.deploy_account_id}:role/codebuild-forms-admin-deploy-${var.env_name}",
        "arn:aws:iam::${local.deploy_account_id}:role/codebuild-forms-runner-deploy-${var.env_name}"
      ]
    }
  }
}

resource "aws_iam_role" "deployer" {
  name               = "deployer-${var.env_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "admin" { //TODO: lock this down when its working
  #checkov:skip=CKV_AWS_274:Removal of Admin Access is TBD https://trello.com/c/nlWAz4SL/417-review-deployer-admin-access
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.deployer.id
}

