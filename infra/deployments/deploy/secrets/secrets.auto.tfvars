secrets_in_environment_type = {
  # For each environment type, we list the names of the variable representing a secret that must exist in that environment type. 
  # The secret's name and description are in the variable external_environment_type_secrets.
  # Global secrets (ones that have the same value across all environment types) do not have to be listed here. Global secrets are in the variable external_global_secrets.
  development = [
    "account_contact_email",
    "account_emergency_email",
  ]

  production = [
    "account_contact_email",
    "account_emergency_email",
  ]

  review = [
    "account_contact_email"
  ]
}


external_environment_type_secrets = {
  account_contact_email = {
    name        = "account/contact-email"
    description = "Email address to contact the GOV.UK Forms team"
  }

  account_emergency_email = {
    name        = "account/emergency-email"
    description = "Emergency email address to contact the GOV.UK Forms team. This is likely something like the PagerDuty email address where the team can be contacted out of hours"
  }
}

external_global_secrets = {
  # The secret value is the same in all environment types where this secret exists. It does not mean the secret exists in all environments
  sentry_dsn_forms_admin = {
    name        = "sentry/dsn/forms-admin"
    description = "Sentry DSN (Data Name Source) to send events from forms-admin to the correct Sentry project"
  }
}
