module "account" {
  source = "../../../modules/account"
}

# Deploy account doesn't use public buckets, so we can safely block public access account-wide
resource "aws_s3_account_public_access_block" "block_public_access" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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
