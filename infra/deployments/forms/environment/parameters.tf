data "aws_caller_identity" "current" {}

removed {
  from = aws_ssm_parameter.auth0_access_client_id

  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_ssm_parameter.auth0_access_client_secret

  lifecycle {
    destroy = false
  }
}
