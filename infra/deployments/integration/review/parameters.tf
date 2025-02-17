resource "aws_ssm_parameter" "traefik_basic_auth_credentials" {
  #checkov:skip=CKV_AWS_337:KMS managed key is fine
  name  = "/review/traefik/basic_auth_credentials"
  type  = "SecureString"
  value = "dummy_value"

  description = "Credentials used by Traefik for basic authentication"

  lifecycle {
    ignore_changes = [value]
  }
}

data "aws_ssm_parameter" "traefik_basic_auth_credentials" {
  name = "/review/traefik/basic_auth_credentials"

  depends_on = [aws_ssm_parameter.traefik_basic_auth_credentials]
}