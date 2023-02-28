locals {
  # Users must have an IAM user within the gds-users account before they can be
  # given access to the GOV.UK Forms accounts. To request an IAM user:
  # https://gds-request-an-aws-account.cloudapps.digital/user

  # The deploy account has access to deploy to production. As always access
  # should be based on least privilege for a given user to perform their duties
  admins = [
    "alice.carr", # Admin whilst setting up the deploy account
    "dan.worth",  # Admin whilst setting up the deploy account
  ]

  # GOV.UK Forms developers that have completed onboarding and support the
  # platform can have this role
  support = [
    "alice.carr",
    "alistair.laing",
    "dan.worth",
    "david.biddle",
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

  pentesters = [
    "alice.carr",
    "dan.worth",
    "david.cliff",
    #"felix.ryan" #Waiting for their gds-users IAM user to be created.
  ]
}

module "engineer_access" {
  source     = "../../../modules/engineer-access"
  admins     = local.admins
  readonly   = local.readonly
  pentesters = local.pentesters
  support    = local.support
  env_name   = "deploy"
}
