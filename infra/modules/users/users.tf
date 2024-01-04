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

  envs  = ["deploy", "staging", "production", "development", "user_research"]
  roles = ["admin", "support", "readonly"]

  users = {
    "alice.carr" = {
      deploy        = "admin" # Admin whilst setting up the deploy account
      staging       = "admin" # Required whilst setting up environments
      production    = "admin" # Required whilst setting up environments
      development   = "admin"
      user_research = "admin"
    },
    "alistair.laing" = {
      deploy        = "support"
      staging       = "support"
      production    = "support"
      development   = "admin"
      user_research = "admin"
    },
    "andy.hunt" = {
      deploy        = "admin"
      staging       = "admin"
      production    = "admin"
      development   = "admin"
      user_research = "admin"
    },
    "catalina.garcia" = {
      deploy        = "admin" # Admin to apply changes to pipelines until we have pipelines for our pipelines
      staging       = "admin" # Required whilst setting up environments
      production    = "admin" # Required whilst setting up environments
      development   = "admin"
      user_research = "admin"
    },
    "dan.worth" = {
      deploy        = "admin" # Admin whilst setting up the deploy account
      staging       = "admin" # Required whilst setting up environments
      production    = "admin" # Required whilst setting up environments
      development   = "admin"
      user_research = "admin"
    },
    "david.biddle" = {
      deploy        = "support"
      staging       = "support"
      production    = "support"
      development   = "admin"
      user_research = "admin"
    },
    "james.sheppard" = {
      deploy        = "readonly"
      staging       = "readonly"
      production    = "readonly"
      development   = "admin"
      user_research = "admin"
    },
    "jamie.wilkinson" = {
      deploy        = "support"
      staging       = "support"
      production    = "support"
      development   = "admin"
      user_research = "admin"
    },
    "kelvin.gan" = {
      deploy        = "admin" # Feature Team Tech lead
      staging       = "admin" # Feature Team Tech lead
      production    = "admin" # Feature Team Tech lead
      development   = "admin"
      user_research = "admin"
    },
    "laurence.debruxelles" = {
      deploy        = "admin" # Knows Terraform well, we are short of SREs. This is for at least a week.
      staging       = "admin" # Knows Terraform well, we are short of SREs. This is for at least a week.
      production    = "admin" # Knows Terraform well, we are short of SREs. This is for at least a week.
      development   = "admin"
      user_research = "admin"
    },
    "radha.kotyankar" = {
      deploy        = "support"
      staging       = "support"
      production    = "support"
      development   = "admin"
      user_research = "support"
    },
    "samuel.culley" = {
      deploy        = "support"
      staging       = "support"
      production    = "support"
      development   = "admin"
      user_research = "admin"
    },
    "tom.iles" = {
      deploy        = "support"
      staging       = "support"
      production    = "support"
      development   = "admin"
      user_research = "admin"
    },
  }
}
