# The database passwords were manually generated when creating the environments
# Note that the RDS docs use the terminology 'master password' - we are using 'root password'
resource "aws_ssm_parameter" "database_password_for_root_user" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name        = "/${var.identifier}/database/root-password"
  description = "Password for the default root user created by Terraform"
  type        = "SecureString"
  value       = "dummy-value"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "database_password" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key
  # count = contains(var.apps_list, "forms-admin") ? 1 : 0
  for_each = toset(var.apps_list)

  name        = "/${each.value}-${var.env_name}/database/password"
  description = "Password for the ${each.value}-app user in the ${each.value} database in the ${var.env_name} environment"
  type        = "SecureString"
  value       = "dummy-value"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}
moved {
  from = aws_ssm_parameter.database_password_for_forms_admin_app
  to   = aws_ssm_parameter.database_password["forms-admin"]
}
moved {
  from = aws_ssm_parameter.database_password_for_forms_api_app
  to   = aws_ssm_parameter.database_password["forms-api"]
}
moved {
  from = aws_ssm_parameter.database_url_for_forms_admin_app
  to   = aws_ssm_parameter.database_url["forms-admin"]
}
moved {
  from = aws_ssm_parameter.database_url_for_forms_api_app
  to   = aws_ssm_parameter.database_url["forms-api"]
}

resource "aws_ssm_parameter" "database_url" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key
  for_each = toset(var.apps_list)

  name        = "/${each.value}-${var.env_name}/database/url"
  description = "URL for connecting to the ${each.value} database in the ${var.env_name} environment using the ${each.value}-app user"
  type        = "SecureString"
  value       = "dummy-value"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}
