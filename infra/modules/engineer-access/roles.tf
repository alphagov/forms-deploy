module "admin_roles" {
  for_each = toset(var.admins)

  source              = "../gds-user-role/"
  email               = "${each.value}@digital.cabinet-office.gov.uk"
  role_suffix         = "admin"
  iam_policy_arns     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  restrict_to_gds_ips = var.vpn
}

module "readonly_roles" {
  for_each = toset(var.readonly)

  source              = "../gds-user-role/"
  email               = "${each.value}@digital.cabinet-office.gov.uk"
  role_suffix         = "readonly"
  iam_policy_arns     = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  restrict_to_gds_ips = var.vpn
}

module "pentester_role" {
  for_each = toset(var.pentesters)

  source      = "../gds-user-role/"
  email       = "${each.value}@digital.cabinet-office.gov.uk"
  role_suffix = "pentester"
  iam_policy_arns = [
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    "arn:aws:iam::aws:policy/SecurityAudit"
  ]
  restrict_to_gds_ips = var.vpn
}

