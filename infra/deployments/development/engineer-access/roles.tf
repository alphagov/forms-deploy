locals {
  # All GOV.UK Forms developers should have admin access to
  # the development environment. Make sure they have an IAM user
  # within the gds-users account. To request an IAM user user:
  # https://gds-request-an-aws-account.cloudapps.digital/user
  admins = [
    "dan.worth",
    "tristram.oaten"
  ]
}

module "engineer_access" {
  source = "../../../modules/engineer-access"
  admins = local.admins
}
