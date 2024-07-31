module "account" {
  source = "../../../modules/account"
}

# Sometimes we log in to Docker when pulling images
# Docker limits the number of images you can pull to 100 without authenticating
resource "aws_ssm_parameter" "docker_username" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name        = "/docker/username"
  description = "The username for accessing the Docker registry"
  type        = "SecureString"
  value       = "dummy-value"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

import {
  id = "/development/dockerhub/username"
  to = aws_ssm_parameter.docker_username
}

resource "aws_ssm_parameter" "docker_password" {
  #checkov:skip=CKV_AWS_337:The parameter is already using the default key

  name        = "/docker/password"
  description = "The password for accessing the Docker registry"
  type        = "SecureString"
  value       = "dummy-value"

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

import {
  id = "/development/dockerhub/password"
  to = aws_ssm_parameter.docker_password
}