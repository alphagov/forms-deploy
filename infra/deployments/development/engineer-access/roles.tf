locals {
  # All GOV.UK Forms developers should have admin access to
  # the development environment. Make sure they have an IAM user
  # within the gds-users account. To request an IAM user user:
  # https://gds-request-an-aws-account.cloudapps.digital/user
  admins = [
    "alice.carr",
    "alistair.laing",
    "dan.worth",
    "david.biddle",
    "samuel.culley",
    "tom.iles",
    "tristram.oaten"
  ]
  readonly = [
    "dan.worth"
  ]
}

module "engineer_access" {
  source   = "../../../modules/engineer-access"
  admins   = local.admins
  readonly = local.readonly
}
