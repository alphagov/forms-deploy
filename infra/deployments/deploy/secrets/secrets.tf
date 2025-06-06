locals {
  secrets_in_environment_type = flatten([
    for environment_type, secrets_set in var.secrets_in_environment_type : [
      for secret in secrets_set : {
        environment_type = environment_type
        name             = "/external/${environment_type}/${var.external_environment_type_secrets[secret].name}"
        description      = var.external_environment_type_secrets[secret].description
      }
    ]
  ])
}

resource "aws_secretsmanager_secret" "external_environment_type" {
  for_each = { for secret in local.secrets_in_environment_type : "${secret.name}-${secret.environment_type}" => secret }

  name        = each.value.name
  description = each.value.description
}

resource "aws_secretsmanager_secret" "external_global" {
  for_each = var.external_global_secrets

  name        = "/external/global/${each.value.name}"
  description = each.value.description
}
