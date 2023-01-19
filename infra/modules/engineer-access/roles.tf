variable "admins" {
  type        = list(string)
  default     = []
  description = "user names for engineers to have admin access"
}

variable "readonly" {
  type        = list(string)
  default     = []
  description = "user names for engineers to have readonly access"
}

variable "vpn" {
  type        = bool
  default     = true
  description = "If true then user must be on the VPN to assume the role"
}

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
