locals {
  # Users must have an IAM user within the gds-users account before they can be
  # given access to the GOV.UK Forms accounts. To request an IAM user:
  # https://gds-request-an-aws-account.cloudapps.digital/user

  # All GOV.UK Forms developers can have admin access to the user research
  # account.
  admins = [
    "alice.carr",
    "alistair.laing",
    "catalina.garcia",
    "dan.worth",
    "david.biddle",
    "james.sheppard",
    "laurence.debruxelles",
    "samuel.culley",
    "tom.iles"
  ]

  # GOV.UK Forms developers that have completed onboarding and support the
  # platform can have this role
  support = [
    "alice.carr",
    "alistair.laing",
    "catalina.garcia",
    "dan.worth",
    "david.biddle",
    "laurence.debruxelles",
    "samuel.culley",
    "tom.iles"
  ]

  readonly = [
    "alice.carr",
    "alistair.laing",
    "catalina.garcia",
    "dan.worth",
    "david.biddle",
    "james.sheppard",
    "laurence.debruxelles",
    "samuel.culley",
    "tom.iles"
  ]
}

module "engineer_access" {
  source   = "../../../modules/engineer-access"
  env_name = "user-research"
  admins   = local.admins
  readonly = local.readonly
  support  = local.support
  vpn      = false
}
