module "users" {
  source = "../../../modules/users"
}

data "aws_caller_identity" "current" {}

locals {
  # Define all the ECS task execution role names that need access to secrets
  ecs_task_execution_role_names = [
    "forms-admin-ecs-task-execution",
    "forms-api-ecs-task-execution",
    "forms-runner-ecs-task-execution",
    "forms-product-page-ecs-task-execution",
    "forms-runner-queue-worker-ecs-task-exec"
  ]

  # Generate role ARNs for each environment type
  environment_type_role_arns = {
    for env_type, account_id in local.environment_type_to_account_id : env_type => [
      for role_name in local.ecs_task_execution_role_names :
      "arn:aws:iam::${account_id}:role/${local.environment_type_to_name[env_type]}-${role_name}"
    ]
  }
}

resource "aws_kms_key" "external_environment_type" {
  for_each = toset(keys(var.secrets_in_environment_type))

  description         = "Symmetric encryption KMS key for external secrets in ${each.value} environments"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms_management_environment_type[each.value].json
}

resource "aws_kms_key" "external_global" {
  description         = "Symmetric encryption KMS key for external global secrets. This key is used by all environment types"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms_management_global.json
}

# KMS policy for environment-type specific keys - allows access from the specific environment account
data "aws_iam_policy_document" "kms_management_environment_type" {
  for_each = toset(keys(var.secrets_in_environment_type))

  # See https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-root-enable-iam
  #checkov:skip=CKV_AWS_111:AWS suggest the EnableIamAccess statement for key policies.
  #checkov:skip=CKV_AWS_109:AWS suggest the EnableIamAccess statement for key policies.
  #checkov:skip=CKV_AWS_356:Resource "*" is OK here because the only resource it can refer to is the key to which the policy is attached

  statement {
    sid    = "EnableIAMAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowAdministrationOfTheKeyByAdminsOfThisAccount" # TODO: check permissions for readonly / support access levels
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [for admin in module.users.with_role["deploy_admin"] : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${admin}-admin"]
    }
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    resources = ["*"]
  }

  # Allow ECS task execution roles from the appropriate environment account to decrypt secrets
  dynamic "statement" {
    for_each = contains(keys(local.environment_type_to_account_id), each.key) ? [1] : []

    content {
      sid    = "AllowECSTaskExecutionRolesToDecryptSecrets"
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = local.environment_type_role_arns[each.key]
      }
      actions = [
        "kms:DescribeKey",
        "kms:Decrypt"
      ]
      resources = ["*"]
      condition {
        test     = "StringEquals"
        variable = "kms:ViaService"
        values   = ["secretsmanager.eu-west-2.amazonaws.com"]
      }
    }
  }
}

# KMS policy for global keys - allows access from all environment accounts
data "aws_iam_policy_document" "kms_management_global" {
  # See https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-root-enable-iam
  #checkov:skip=CKV_AWS_111:AWS suggest the EnableIamAccess statement for key policies.
  #checkov:skip=CKV_AWS_109:AWS suggest the EnableIamAccess statement for key policies.
  #checkov:skip=CKV_AWS_356:Resource "*" is OK here because the only resource it can refer to is the key to which the policy is attached

  statement {
    sid    = "EnableIAMAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowAdministrationOfTheKeyByAdminsOfThisAccount" # TODO: check permissions for readonly / support access levels
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [for admin in module.users.with_role["deploy_admin"] : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${admin}-admin"]
    }
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    resources = ["*"]
  }

  # Allow ECS task execution roles from all environment accounts to decrypt global secrets
  statement {
    sid    = "AllowECSTaskExecutionRolesToDecryptGlobalSecrets"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = flatten([for role_arns in values(local.environment_type_role_arns) : role_arns])
    }
    actions = [
      "kms:DescribeKey",
      "kms:Decrypt"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["secretsmanager.eu-west-2.amazonaws.com"]
    }
  }
}
