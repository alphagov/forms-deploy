external_env_type_secrets = {
  # These secrets are "external" because we use them to talk to third party services
  # They are grouped by environment type because they are the same in all instances of a type of environment (e.g. development, production)
  # In Secrets Manager the secret is "external/ENVIRONMENT_TYPE/NAME" where "NAME" is the one defined here

  account_contact_phone_number = {
    name        = "account/contact-phone-number"
    description = ""
  }
  account_contact_email = {
    name        = "account/contact-email"
    description = ""
  }
  account_emergency_email = {
    name        = "account/emergency-email"
    description = ""
  }
  account_emergency_phone_number = {
    name        = "account/emergency-phone-number"
    description = ""
  }
  auth0_splunk_hec_token = {
    name        = "auth0/splunk-hec-token"
    description = ""
  }
  auth0_machine_user_email = {
    name        = "auth0/machine-user/email"
    description = ""
  }
  auth0_machine_user_password = {
    name        = "auth0/machine-user/password"
    description = ""
  }
  dockerhub_username = {
    name        = "dockerhub/username"
    description = ""
  }
  dockerhub_password = {
    name        = "dockerhub/password"
    description = ""
  }
  google_oauth_client_secret = {
    name        = "google/oauth/client-secret"
    description = ""
  }
  google_oauth_client_id = {
    name        = "google/oauth/client-id"
    description = ""
  }
  mailchimp_api_key = {
    name        = "mailchimp/api-key"
    description = ""
  }
  terraform_auth0_access_client_id = {
    name        = "auth0-access/client-id"
    description = "The client ID for the Auth0 'Terraform access' app for this environment"
  }
  terraform_auth0_access_client_secret = {
    name        = "auth0-access/client-secret"
    description = "The client secret for the Auth0 'Terraform access' app for this environment"
  }
  zendesk_api_user = {
    name        = "zendesk/api-user"
    description = "API user to connect to Zendesk"
  }
  zendesk_api_key = {
    name        = "zendesk/api-key"
    description = "API key to connect to Zendesk"
  }
}

external_global_secrets = {
  # These secrets are "external" because we use them to talk to third party services
  # These secrets are "global" because their values are the same across all environments
  # In Secrets Manger the secret is "external/global/NAME" where "NAME" is the one defined here.
  pagerduty_integration_url = {
    name        = "pagerduty/integration-url"
    description = "URL containing the PagerDuty Integration Key to allow Amazon CloudWatch integration"
  }
  sentry_dsn_forms_admin = {
    name        = "sentry/dsn/forms-admin"
    description = "Sentry DSN (Data Name Source) to send events from forms-admin to the correct Sentry project"
  }
  sentry_dsn_forms_api = {
    name        = "sentry/dsn/forms-api"
    description = "Sentry DSN (Data Name Source) to send events from forms-forms-api to the correct Sentry project"
  }
  sentry_dsn_forms_product_page = {
    name        = "sentry/dsn/forms-product-page"
    description = "Sentry DSN (Data Name Source) to send events from forms-product-page to the correct Sentry project"
  }
  sentry_dsn_forms_runner = {
    name        = "sentry/dsn/forms-runner"
    description = "Sentry DSN (Data Name Source) to send events from forms-runner to the correct Sentry project"
  }
  zendesk_inbound_email = {
    name        = "zendesk/inbound-email"
    description = "Support email for GOV.UK Forms Zendesk"
  }
}