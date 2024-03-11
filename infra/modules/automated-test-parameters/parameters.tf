#NOTE: The data resources are only required whilst we migrate the parameters
#between name spaces. Subsequent PR will remove them and set the values to
#dummy-value

data "aws_ssm_parameter" "auth0_username" {
  name = "/${var.environment_name}/smoketests/auth0/email-username"
}

resource "aws_ssm_parameter" "auth0_username" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name  = "/${var.environment_name}/automated-tests/e2e/auth0/email-username"
  type  = "SecureString"
  value = data.aws_ssm_parameter.auth0_username.value

  lifecycle {
    ignore_changes = [value]
  }
}

data "aws_ssm_parameter" "auth0_user_password" {
  name = "/${var.environment_name}/smoketests/auth0/auth0-user-password"
}

resource "aws_ssm_parameter" "auth0_user_password" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name  = "/${var.environment_name}/automated-tests/e2e/auth0/auth0-user-password"
  type  = "SecureString"
  value = data.aws_ssm_parameter.auth0_user_password.value

  lifecycle {
    ignore_changes = [value]
  }
}

data "aws_ssm_parameter" "notify_api_key" {
  name = "/${var.environment_name}/smoketests/notify/api-key"
}

resource "aws_ssm_parameter" "notify_api_key" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name  = "/${var.environment_name}/automated-tests/e2e/notify/api-key"
  type  = "SecureString"
  value = data.aws_ssm_parameter.notify_api_key.value

  lifecycle {
    ignore_changes = [value]
  }
}
