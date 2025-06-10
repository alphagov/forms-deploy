all_internal_secrets = {
  # Secrets for use with/by internal components
  databases_forms_admin_app_password = {
    name        = "databases/forms-admin/app-password"
    description = "Password for the forms-admin-app user in the forms-admin database"
  }

  databases_forms_admin_app_url = {
    name        = "databases/forms-admin/app-url"
    description = "URL for connecting to the forms-admin database using the forms-admin-app user"
  }

  databases_forms_admin_root_password = {
    name        = "databases/forms-admin/root-password"
    description = "Password for the default root user created by Terraform"
  }

  databases_forms_api_app_password = {
    name        = "databases/forms-api/app-password"
    description = "Password for the forms-api-app user in the forms-api database"
  }

  databases_forms_api_app_url = {
    name        = "databases/forms-api/app-url"
    description = "URL for connecting to the forms-api database using the forms-api-app user"
  }

  databases_forms_runner_app_password = {
    name        = "databases/forms-runner/app-password"
    description = "Password for the forms-runner-app user in the forms-runner database"
  }

  databases_forms_runner_app_url = {
    name        = "databases/forms-runner/app-url"
    description = "URL for connecting to the forms-runner database using the forms-runner-app user"
  }

  databases_forms_runner_root_password = {
    name        = "databases/forms-runner/root-password"
    description = "Password for the default root user created by Terraform"
  }

  databases_forms_runner_queue_password = {
    name        = "databases/forms-runner/queue-password"
    description = "Password for the forms-runner-queue-app user in the forms-runner-queue database"
  }

  databases_forms_runner_queue_url = {
    name        = "databases/forms-runner/queue-url"
    description = "URL for connecting to the forms-runner-queue database using the forms-runner-queue-app user"
  }

  forms_admin_forms_api_key = {
    name        = "forms-admin/forms-api-key"
    description = "API key to access forms-api"
  }

  forms_admin_secret_key_base = {
    name        = "forms-admin/secret-key-base"
    description = "Rails secret_key_base value for forms-admin"
  }

  forms_api_forms_api_key = {
    name        = "forms-api/forms-api-key"
    description = "API key to access forms-api"
  }

  forms_api_secret_key_base = {
    name        = "forms-api/secret-key-base"
    description = "Rails secret_key_base value for forms-api"
  }

  forms_product_page_secret_key_base = {
    name        = "forms-product-page/secret-key-base"
    description = "Rails secret_key_base value for forms-product-page"
  }

  forms_runner_e2e_tests_submissions_status_api_shared_secret = {
    name        = "forms-runner/e2e-tests/submission-status-api-shared-secret"
    description = "Secret value shared by forms-runner and end-to-end tests to authorize the attachment sent endpoint. We use the 'dev' value in all environments"
  }

  forms_runner_forms_api_key = {
    name        = "forms-runner/forms-api-key"
    description = "API key to access forms-api"
  }

  forms_runner_secret_key_base = {
    name        = "forms-runner/secret-key-base"
    description = "Rails secret_key_base value for forms-runner"
  }

  forms_runner_submission_status_api_shared_secret = {
    name        = "forms-runner/submission-status-api-shared-secret"
    description = "Secret value shared by forms-runner and end-to-end tests to authorize the attachment sent endpoint"
  }

  ses_auth0_smtp_password = {
    name        = "ses/auth0-smtp-password"
    description = "SMTP password to configure Auth0 with SES"
  }

  ses_auth0_smtp_username = {
    name        = "ses/auth0-smtp-username"
    description = "SMTP username to configure Auth0 with SES"
  }
}
