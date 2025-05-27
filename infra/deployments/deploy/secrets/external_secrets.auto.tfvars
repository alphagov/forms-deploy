external_env_type_secrets = {
  # In Secrets Manager the secret will be `external/ENVIRONMENT_TYPE/NAME` where `NAME` is the one defined here

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
