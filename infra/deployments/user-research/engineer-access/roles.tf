locals {
  # Users must have an IAM user within the gds-users account before they can be
  # given access to the GOV.UK Forms accounts. To request an IAM user:
  # https://gds-request-an-aws-account.cloudapps.digital/user

  # All GOV.UK Forms developers can have admin access to the user research
  # account.

  admins = [
    "alice.carr",
    "alistair.laing",
    "dan.worth",
    "david.biddle",
    "james.sheppard",
    "laurence.debruxelles",
    "samuel.culley",
    "tom.iles",
    "tristram.oaten"
  ]

  readonly = [
    "alice.carr",
    "alistair.laing",
    "dan.worth",
    "david.biddle",
    "james.sheppard",
    "laurence.debruxelles",
    "samuel.culley",
    "tom.iles",
    "tristram.oaten"
  ]
}

module "engineer_access" {
  source   = "../../../modules/engineer-access"
  admins   = local.admins
  readonly = local.readonly
  vpn      = false
}
