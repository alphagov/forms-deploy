# Auth0
# These are the client ID and client secret of the machine to machine application in the GOV.UK Forms tenant for the account you are terraforming
# The values are different in each account, and some accounts may not used them (for example, User Research)
resource "aws_ssm_parameter" "auth0_access_client_id" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name        = "/terraform/${var.environment_name}/auth0-access/client-id"
  description = "The client ID for the Auth0 'Terraform access' app for this environment"
  type        = "SecureString"
  value       = "dummy-value"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "auth0_access_client_secret" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name        = "/terraform/${var.environment_name}/auth0-access/client-secret"
  description = "The client secret for the Auth0 'Terraform access' app for this environment"
  type        = "SecureString"
  value       = "dummy-value"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

# Shared secret between end-to-end tests and runner
# Used to secure the endpoint which reports whether an email
# was sent for use by the end-to-end tests. We don't want that
# endpoint to be completely unauthenticated and unauthorized, out of an abundance
# of caution
resource "random_password" "submission_status_api_shared_secret" {
  length = 20
}

resource "aws_ssm_parameter" "submission_status_api_shared_secret" {
  #checkov:skip=CKV_AWS_337:It's fine to use the managed key
  name        = "/forms-runner-${var.environment_name}/submission_status_api_shared_secret"
  type        = "SecureString"
  description = "Secret value shared by forms-runner and end-to-end tests to authorize the attachment sent endpoint"
  value       = random_password.submission_status_api_shared_secret.result

  lifecycle {
    ignore_changes = [value]
  }
}
