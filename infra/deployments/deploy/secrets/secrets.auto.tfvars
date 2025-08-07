secrets_in_environment_type = {
  # For each environment type, we list the names of the variable representing a secret that must exist in that environment type. 
  # The secret's name and description are in the variable external_environment_type_secrets.
  # Global secrets (ones that have the same value across all environment types) do not have to be listed here. Global secrets are in the variable external_global_secrets.
  development = [
    "account_contact_email",
    "account_contact_phone_number",
    # "account_emergency_email",
    # "account_emergency_phone_number",
    # "auth0_e2e_tests_machine_user_client_id",
    # "auth0_e2e_tests_machine_user_client_secret",
    # "auth0_e2e_tests_machine_user_password",
    # "auth0_e2e_tests_machine_user_username",
    # "auth0_forms_admin_client_id",
    # "auth0_forms_admin_client_secret",
    # "auth0_forms_admin_domain",
    # "auth0_splunk_hec_token",
    # "auth0_terraform_client_id",
    # "auth0_terraform_client_secret",
    # "gds_sso_oauth_client_id",
    # "gds_sso_oauth_client_secret",
    # "google_oauth_client_id",
    # "google_oauth_client_secret",
    # "mailchimp_api_key",
    # "notify_e2e_tests_api_key",
    # "notify_forms_admin_api_key",
    # "notify_forms_runner_api_key",
    # "zendesk_api_user",
    # "zendesk_api_key",
  ]

  staging = [
    # "account_contact_email",
    # "account_contact_phone_number",
    # "account_emergency_email",
    # "account_emergency_phone_number",
    # "auth0_e2e_tests_machine_user_client_id",
    # "auth0_e2e_tests_machine_user_client_secret",
    # "auth0_e2e_tests_machine_user_password",
    # "auth0_e2e_tests_machine_user_username",
    # "auth0_forms_admin_client_id",
    # "auth0_forms_admin_client_secret",
    # "auth0_forms_admin_domain",
    # "auth0_splunk_hec_token",
    # "auth0_terraform_client_id",
    # "auth0_terraform_client_secret",
    # "gds_sso_oauth_client_id",
    # "gds_sso_oauth_client_secret",
    # "google_oauth_client_id",
    # "google_oauth_client_secret",
    # "mailchimp_api_key",
    # "notify_e2e_tests_api_key",
    # "notify_forms_admin_api_key",
    # "notify_forms_runner_api_key",
    # "zendesk_api_user",
    # "zendesk_api_key",
  ]

  production = [
    # "account_contact_email",
    # "account_contact_phone_number",
    # "account_emergency_email",
    # "account_emergency_phone_number",
    # "auth0_e2e_tests_machine_user_client_id",
    # "auth0_e2e_tests_machine_user_client_secret",
    # "auth0_e2e_tests_machine_user_password",
    # "auth0_e2e_tests_machine_user_username",
    # "auth0_forms_admin_client_id",
    # "auth0_forms_admin_client_secret",
    # "auth0_forms_admin_domain",
    # "auth0_splunk_hec_token",
    # "auth0_terraform_client_id",
    # "auth0_terraform_client_secret",
    # "gds_sso_oauth_client_id",
    # "gds_sso_oauth_client_secret",
    # "google_oauth_client_id",
    # "google_oauth_client_secret",
    # "mailchimp_api_key",
    # "notify_e2e_tests_api_key",
    # "notify_forms_admin_api_key",
    # "notify_forms_runner_api_key",
    # "zendesk_api_user",
    # "zendesk_api_key",
  ]

  user-research = [
    # "account_contact_email",
    # "account_contact_phone_number",
    # "account_emergency_email",
    # "account_emergency_phone_number",
    # "auth0_forms_admin_client_id",
    # "auth0_forms_admin_client_secret",
    # "auth0_forms_admin_domain",
    # "auth0_terraform_client_id",
    # "auth0_terraform_client_secret",
    # "basic_auth_password",
    # "basic_auth_username",
    # "cddo_sso_oauth_client_id",
    # "cddo_sso_oauth_client_secret",
    # "mailchimp_api_key",
    # "notify_e2e_test_api_key",
    # "notify_forms_admin_api_key",
    # "notify_forms_runner_api_key",
    # "zendesk_api_user",
    # "zendesk_api_key",
  ]

  deploy = [
    "account_contact_email",
    "account_contact_phone_number",
  ]

  review = [
    # "account_contact_email",
    # "account_contact_phone_number",
    # "traefik_basic_auth_credentials",
  ]

  ithc = [
  ]
}

external_environment_type_secrets = {
  account_contact_email = {
    name        = "account/contact-email"
    description = "Email address to contact the GOV.UK Forms team"
  }

  account_contact_phone_number = {
    name        = "account/contact-phone-number"
    description = "Phone number to contact the GOV.UK Forms team"
  }

  account_emergency_phone_number = {
    name        = "account/emergency-phone-number"
    description = "Emergency phone number to contact the GOV.UK Forms team. This is likely something like the PagerDuty phone number where the team can be contacted out of hours"
  }

  account_emergency_email = {
    name        = "account/emergency-email"
    description = "Emergency email address to contact the GOV.UK Forms team. This is likely something like the PagerDuty email address where the team can be contacted out of hours"
  }

  auth0_e2e_tests_machine_user_client_id = {
    name        = "auth0/e2e-tests-machine-user/client-id"
    description = "Auth0 client ID to use with end to end tests"
  }

  auth0_e2e_tests_machine_user_client_secret = {
    name        = "auth0/e2e-tests-machine-user/client-secret"
    description = "Auth0 client secret to use with end to end tests"
  }

  auth0_e2e_tests_machine_user_password = {
    name        = "auth0/e2e-tests-machine-user/password"
    description = "Auth0 password for e2e tests to login to forms-admin"
  }

  auth0_e2e_tests_machine_user_username = {
    name        = "auth0/e2e-tests-machine-user/username"
    description = "Auth0 username for e2e tests to login to forms-admin"
  }

  auth0_forms_admin_client_id = {
    name        = "auth0/forms-admin/client-id"
    description = "Auth0 client ID for forms-admin"
  }

  auth0_forms_admin_client_secret = {
    name        = "auth0/forms-admin/client-secret"
    description = "Auth0 client secret for forms-admin"
  }

  auth0_forms_admin_domain = {
    name        = "auth0/forms-admin/domain"
    description = "Auth0 domain for forms-admin"
  }

  auth0_splunk_hec_token = {
    name        = "auth0/splunk-hec-token"
    description = "HEC (HTTP Event Collector) token from Splunk to allow us to stream Auth0 logs"
  }

  auth0_terraform_client_id = {
    name        = "auth0/terraform/client-id"
    description = "Client ID for the Auth0 'Terraform access' app"
  }

  auth0_terraform_client_secret = {
    name        = "auth0/terraform/client-secret"
    description = "Client secret for the Auth0 'Terraform access' app"
  }

  basic_auth_password = {
    name        = "basic-auth/password"
    description = "Password for using basic auth0 (SETTINGS__USER_RESEARCH__AUTH__PASSWORD)"
  }

  basic_auth_username = {
    name        = "basic-auth/username"
    description = "Username for using basic auth0 (SETTINGS__USER_RESEARCH__AUTH__USERNAME)"
  }

  cddo_sso_oauth_client_id = {
    name        = "cddo-sso/client-id"
    description = "Identifier for OpenID Connect for CDDO SSO at sso.service.security.gov.uk"
  }

  cddo_sso_oauth_client_secret = {
    name        = "cddo-sso/client-secret"
    description = "Secret for OpenID Connect for CDDO SSO at sso.service.security.gov.uk"
  }

  gds_sso_oauth_client_id = {
    name        = "/gds-sso-oauth/client-id"
    description = "Oauth ID to authenticate forms-admin-dev with GOVUK Signon"
  }

  gds_sso_oauth_client_secret = {
    name        = "/gds-sso-oauth/client-secret"
    description = "Oauth secret to authenticate forms-admin-dev with GOVUK Signon"
  }

  google_oauth_client_id = {
    name        = "google/oauth/client-id"
    description = "Client ID for Google OAuth"
  }

  google_oauth_client_secret = {
    name        = "google/oauth/client-secret"
    description = "Client secret for Google OAuth"
  }

  mailchimp_api_key = {
    name        = "mailchimp/api-key"
    description = "API key to connect to Mailchimp"
  }

  notify_e2e_tests_api_key = {
    name        = "notify/e2e-tests/api-key"
    description = "API key for e2e tests to connect to GOV.UK Notify"
  }

  notify_forms_admin_api_key = {
    name        = "notify/forms-admin/api-key"
    description = "API key for forms-admin to connect to GOV.UK Notify"
  }

  notify_forms_runner_api_key = {
    name        = "notify/forms-runner/api-key"
    description = "API key for forms-runner to connect to GOV.UK Notify"
  }

  traefik_basic_auth_credentials = {
    name        = "traefik/basic-auth-credentials"
    description = "Credentials used by Traefik for basic authentication"
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
  # The secret value is the same in all environment types where this secret is used. It does not mean the secret is used in all environments
  dockerhub_password = {
    name        = "dockerhub/password"
    description = "The password for the Docker registry"
  }

  # dockerhub_username = {
  #   name        = "dockerhub/username"
  #   description = "The password for the Docker registry"
  # }

  # pagerduty_integration_url = {
  #   name        = "pagerduty/integration-url"
  #   description = "URL containing the PagerDuty Integration Key to allow Amazon CloudWatch integration"
  # }

  # sentry_dsn_forms_admin = {
  #   name        = "sentry/dsn/forms-admin"
  #   description = "Sentry DSN (Data Name Source) to send events from forms-admin to the Sentry project"
  # }

  # sentry_dsn_forms_api = {
  #   name        = "sentry/dsn/forms-api"
  #   description = "Sentry DSN (Data Name Source) to send events from forms-forms-api to the Sentry project"
  # }

  # sentry_dsn_forms_product_page = {
  #   name        = "sentry/dsn/forms-product-page"
  #   description = "Sentry DSN (Data Name Source) to send events from forms-product-page to the Sentry project"
  # }

  # sentry_dsn_forms_runner = {
  #   name        = "sentry/dsn/forms-runner"
  #   description = "Sentry DSN (Data Name Source) to send events from forms-runner to the Sentry project"
  # }

  # sentry_dsn_forms_runner_queue_worker = {
  #   name        = "sentry/dsn/forms-runner-queue-worker"
  #   description = "Sentry DSN (Data Name Source) to send events from forms-runner-queue-worker to the Sentry project"
  # }

  # zendesk_inbound_email = {
  #   name        = "zendesk/inbound-email"
  #   description = "Support email for GOV.UK Forms Zendesk"
  # }
}
