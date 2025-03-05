locals {
  # Developers must have an IAM user within the gds-users account before they
  # can be given access to the GOV.UK Forms AWS accounts. To request an IAM user:
  # https://gds-request-an-aws-account.cloudapps.digital/user

  # Admin access to the deploy, staging, and production environments should
  # only be provided when needed.

  # GOV.UK Forms developers that have completed onboarding and support the
  # platform can have the support role

  # All GOV.UK Forms developers can have readonly access to
  # the staging and production environments.

  # All GOV.UK Forms developers can have admin access to the development
  # and user research accounts.

  accounts = ["deploy", "staging", "production", "development", "dev-two", "user_research", "integration"]
  roles    = ["admin", "support", "readonly"]

  users = {
    "alice.carr" = {
      deploy        = "admin" # Admin whilst setting up the deploy account
      staging       = "admin" # Required whilst setting up environments
      production    = "admin" # Required whilst setting up environments
      development   = "admin"
      user_research = "admin"
      integration   = "readonly"
      "dev-two"     = "admin"
    },
    "andy.hunt" = {
      deploy        = "admin"
      staging       = "admin"
      production    = "admin"
      development   = "admin"
      user_research = "admin"
      integration   = "admin"
      "dev-two"     = "admin"
    },
    "catalina.garcia" = {
      deploy        = "admin" # Admin to apply changes to pipelines until we have pipelines for our pipelines
      staging       = "admin" # Required whilst setting up environments
      production    = "admin" # Required whilst setting up environments
      development   = "admin"
      user_research = "admin"
      integration   = "admin"
      "dev-two"     = "admin"
    },
    "david.biddle" = {
      deploy        = "admin"
      staging       = "admin"
      production    = "admin"
      development   = "admin"
      user_research = "admin"
      integration   = "readonly"
      "dev-two"     = "admin"
    },
    "jamie.wilkinson1" = {
      deploy        = "support"
      staging       = "support"
      production    = "support"
      development   = "admin"
      user_research = "admin"
      integration   = "readonly"
      "dev-two"     = "admin"
    },
    "kelvin.gan" = {
      deploy        = "admin" # Feature Team Tech lead
      staging       = "admin" # Feature Team Tech lead
      production    = "admin" # Feature Team Tech lead
      development   = "admin"
      user_research = "admin"
      integration   = "readonly"
      "dev-two"     = "admin"
    },
    "laurence.debruxelles" = {
      deploy        = "admin" # Knows Terraform well, we are short of SREs. This is for at least a week.
      staging       = "admin" # Knows Terraform well, we are short of SREs. This is for at least a week.
      production    = "admin" # Knows Terraform well, we are short of SREs. This is for at least a week.
      development   = "admin"
      user_research = "admin"
      integration   = "readonly"
      "dev-two"     = "admin"
    },
    "max.fitzhugh" = {
      deploy        = "readonly"
      staging       = "readonly"
      production    = "readonly"
      development   = "readonly"
      user_research = "readonly"
      integration   = "readonly"
      "dev-two"     = "readonly"
    },
    "samuel.culley" = {
      deploy        = "admin"
      staging       = "admin"
      production    = "admin"
      development   = "admin"
      user_research = "admin"
      integration   = "readonly"
      "dev-two"     = "admin"
    },
    "sarah.young1" = {
      deploy        = "admin"
      staging       = "admin"
      production    = "admin"
      development   = "admin"
      user_research = "admin"
      integration   = "admin"
      "dev-two"     = "admin"
    },
    "sean.rankine" = {
      deploy        = "admin" # Sean is our Lead Dev and has also worked as a Sr SRE.
      staging       = "admin"
      production    = "admin"
      development   = "admin"
      user_research = "admin"
      integration   = "admin"
      "dev-two"     = "admin"
    },
    "stephen.daly" = {
      deploy        = "admin"
      staging       = "admin"
      production    = "admin"
      development   = "admin"
      user_research = "admin"
      integration   = "readonly"
      "dev-two"     = "admin"
    },
    "tom.iles" = {
      deploy        = "admin"
      staging       = "admin"
      production    = "admin"
      development   = "admin"
      user_research = "admin"
      integration   = "readonly"
      "dev-two"     = "admin"
    },
  }
}
