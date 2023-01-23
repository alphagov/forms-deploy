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

  deploy_account_main_branch_roles = [
    "arn:aws:iam::${local.deploy_account_id}:role/codebuild-forms-api-deploy-${var.env_name}-main-branch",
    "arn:aws:iam::${local.deploy_account_id}:role/codebuild-forms-admin-deploy-${var.env_name}-main-branch",
    "arn:aws:iam::${local.deploy_account_id}:role/codebuild-forms-runner-deploy-${var.env_name}-main-branch"
  ]

  deploy_account_development_branches_roles = [
    "arn:aws:iam::${local.deploy_account_id}:role/codebuild-forms-api-deploy-${var.env_name}-branches",
    "arn:aws:iam::${local.deploy_account_id}:role/codebuild-forms-admin-deploy-${var.env_name}-branches",
    "arn:aws:iam::${local.deploy_account_id}:role/codebuild-forms-runner-deploy-${var.env_name}-branches"
  ]

  deployer_roles_per_env = {
    "user-research" = concat(local.deploy_account_main_branch_roles, local.deploy_account_development_branches_roles),
    "dev"           = concat(local.deploy_account_main_branch_roles, local.deploy_account_development_branches_roles),
    "staging"       = local.deploy_account_main_branch_roles,
    "production"    = local.deploy_account_main_branch_roles
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = lookup(local.deployer_roles_per_env, var.env_name)
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

