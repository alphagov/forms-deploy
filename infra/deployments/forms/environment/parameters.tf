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

moved {
  from = aws_ssm_parameter.auth0_access_client_id_env_specific
  to   = aws_ssm_parameter.auth0_access_client_id
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

moved {
  from = aws_ssm_parameter.auth0_access_client_secret_env_specific
  to   = aws_ssm_parameter.auth0_access_client_secret
}