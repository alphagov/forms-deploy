module "admin_roles" {
  for_each = toset(var.admins)

  source              = "../gds-user-role/"
  email               = "${each.value}@digital.cabinet-office.gov.uk"
  role_suffix         = "admin"
  iam_policy_arns     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  restrict_to_gds_ips = var.vpn
}

module "support_role" {
  for_each = toset(concat(var.admins, var.support))

  source      = "../gds-user-role/"
  email       = "${each.value}@digital.cabinet-office.gov.uk"
  role_suffix = "support"
  iam_policy_arns = flatten([
    "arn:aws:iam::aws:policy/ReadOnlyAccess",
    aws_iam_policy.manage_parameter_store.arn,
    aws_iam_policy.manage_dashboards.arn,
    var.env_name == "deploy" ? [aws_iam_policy.manage_deployments[0].arn] : [],
    var.env_name != "deploy" ? [aws_iam_policy.query_rds_with_data_api[0].arn, aws_iam_policy.run_task[0].arn, aws_iam_policy.stop_task[0].arn] : []
  ])
  restrict_to_gds_ips = var.vpn
}

module "readonly_roles" {
  for_each = toset(concat(var.admins, var.support, var.readonly))

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

