module "users" {
  source = "../../../modules/users"
}

module "common_values" {
  source = "../../../modules/common-values"
}

locals {
  ip_restrictions = var.require_vpn_to_access ? module.common_values.vpn_ip_addresses : []
}

module "admin_roles" {
  for_each = toset(module.users.with_role["integration_admin"])

  source          = "../../../modules/gds-user-role/"
  email           = "${each.value}@digital.cabinet-office.gov.uk"
  role_suffix     = "admin"
  iam_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  ip_restrictions = local.ip_restrictions
}

module "support_roles" {
  for_each = toset(module.users.with_role["integration_support"])

  source      = "../../../modules/gds-user-role/"
  email       = "${each.value}@digital.cabinet-office.gov.uk"
  role_suffix = "support"
  iam_policy_arns = [
    aws_iam_policy.lock_state_files.id
  ]
  ip_restrictions = local.ip_restrictions
}


module "readonly_roles" {
  for_each = toset(module.users.with_role["integration_readonly"])

  source      = "../../../modules/gds-user-role/"
  email       = "${each.value}@digital.cabinet-office.gov.uk"
  role_suffix = "readonly"
  iam_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    aws_iam_policy.lock_state_files.id
  ]
  ip_restrictions = local.ip_restrictions
}


resource "aws_iam_policy" "lock_state_files" {
  name = "lock-state-files"
  path = "/"

  description = "Allow reading and writing from a DynamoDB table used for Terraform state file locking"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = ["arn:aws:dynamodb:eu-west-2:${var.aws_account_id}:table/${var.dynamodb_table}"]
      }
    ]
  })
}
