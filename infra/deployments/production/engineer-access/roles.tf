locals {
  # Users must have an IAM user within the gds-users account before they can be
  # given access to the GOV.UK Forms accounts. To request an IAM user:
  # https://gds-request-an-aws-account.cloudapps.digital/user

  # Admin access to the production environment should only be provided when
  # needed.
  admins = [
    "alice.carr",      // Required whilst setting up environments.
    "dan.worth",       // Required whilst setting up environments.
    "catalina.garcia", // Required whilst setting up environments.
    "kelvin.gan"       // Feature Team Tech lead
  ]

  # GOV.UK Forms developers that have completed onboarding and support the
  # platform can have this role
  support = [
    "alice.carr",
    "alistair.laing",
    "catalina.garcia",
    "dan.worth",
    "david.biddle",
    "jamie.wilkinson",
    "kelvin.gan",
    "laurence.debruxelles",
    "samuel.culley",
    "tom.iles"
  ]

  # All GOV.UK Forms developers can have readonly access to
  # the production environment.
  readonly = [
    "alice.carr",
    "alistair.laing",
    "catalina.garcia",
    "dan.worth",
    "david.biddle",
    "james.sheppard",
    "jamie.wilkinson",
    "kelvin.gan",
    "laurence.debruxelles",
    "samuel.culley",
    "tom.iles"
  ]
}

module "engineer_access" {
  source   = "../../../modules/engineer-access"
  env_name = "production"
  admins   = local.admins
  readonly = local.readonly
  support  = local.support
}
