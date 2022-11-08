locals {
  # Users must have an IAM user within the gds-users account before they can be
  # given access to the GOV.UK Forms accounts. To request an IAM user:
  # https://gds-request-an-aws-account.cloudapps.digital/user

  # Admin access to the staging environment should only be provided when
  # needed.
  admins = [
    "dan.worth" // Required whilst setting up environments.
    "alice.carr" // Required whilst setting up environments.
  ]

  # All GOV.UK Forms developers can have readonly access to
  # the staging environment.
  readonly = [
    "alice.carr",
    "alistair.laing",
    "dan.worth",
    "david.biddle",
    "james.sheppard",
    "samuel.culley",
    "tom.iles",
    "tristram.oaten"
  ]
}

module "engineer_access" {
  source   = "../../../modules/engineer-access"
  admins   = local.admins
  readonly = local.readonly
}
