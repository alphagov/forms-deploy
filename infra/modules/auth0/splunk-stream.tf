resource "auth0_log_stream" "to_splunk" {
  # Note that the splunk_domain is actually for CRIBL, which pre-processes the logs
  count = var.enable_splunk_log_stream ? 1 : 0

  name = "Auth0 to Splunk log stream"
  type = "splunk"

  sink {
    splunk_domain = "gds-general.main.heuristic-bondo-ebxaqj9.cribl.cloud"
    splunk_port   = "8088"
    splunk_secure = true
    splunk_token  = data.aws_ssm_parameter.splunk_hec_token.value
  }
}

resource "aws_ssm_parameter" "splunk_hec_token" {

  #checkov:skip=CKV_AWS_337:The parameter is already using the default key
  # Value is set externally.
  name  = "/${var.env_name}/splunk/auth0_hec_token"
  type  = "SecureString"
  value = "dummy-hec-token"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

data "aws_ssm_parameter" "splunk_hec_token" {
  name = "/${var.env_name}/splunk/auth0_hec_token"

  depends_on = [aws_ssm_parameter.splunk_hec_token]
}
