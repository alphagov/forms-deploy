data "aws_caller_identity" "current" {}

# The database passwords were manually generated when creating the environments
resource "aws_ssm_parameter" "database_password_for_master_user" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name        = "/database/master-password"
  description = "Password for the default master user created by Terraform"
  type        = "SecureString"
  value       = "dummy-value"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "database_password_for_forms_admin_app" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name        = "/forms-admin-${var.env_name}/database/password"
  description = "Password for the forms-admin-app user in the forms-admin database in the ${var.env_name} environment"
  type        = "SecureString"
  value       = "dummy-value"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}


resource "aws_ssm_parameter" "database_url_for_forms_admin_app" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name        = "/forms-admin-${var.env_name}/database/url"
  description = "URL for connecting to the forms-admin database in the ${var.env_name} environment using the forms-admin-app user"
  type        = "SecureString"
  value       = "dummy-value"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "database_password_for_forms_api_app" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name        = "/forms-api-${var.env_name}/database/password"
  description = "Password for the forms-api-app user in the forms-api database in the ${var.env_name} environment"
  type        = "SecureString"
  value       = "dummy-value"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "aws_ssm_parameter" "database_url_for_forms_api_app" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name        = "/forms-api-${var.env_name}/database/url"
  description = "URL for connecting to the forms-api database in the ${var.env_name} environment using the forms-api-app user"
  type        = "SecureString"
  value       = "dummy-value"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}
