locals {
  environment_types = ["development", "staging", "production", "user-research", "deploy", "review", "ithc"]

  secret_resource_names = keys(var.external_env_type_secrets)

  secret_in_environment_type = setproduct(local.environment_types, local.secret_resource_names)
  # pairs environment types and secret resource names, e.g. [["development", "zendesk_api_user"], ["staging", zendesk_api_user], ...]
}

resource "aws_secretsmanager_secret" "external_env_type" {
  # Iterate over unique combinations of environment types and secret resource names
  # pair[0] is the environment type
  # pair[1] is the secret resource name e.g. "zendesk_api_user"
  for_each = { for pair in local.secret_in_environment_type :
    "${pair[0]}/${pair[1]}" => {
      env_type    = pair[0]
      name        = "external/${pair[0]}/${var.external_env_type_secrets[pair[1]].name}"
      description = var.external_env_type_secrets[pair[1]].description
    }
  }

  name        = each.value.name
  description = each.value.description
  kms_key_id  = aws_kms_key.external_env_type[each.value.env_type].id
}

resource "aws_secretsmanager_secret" "external_global" {
  for_each = var.external_global_secrets

  name        = "external/global/${each.value.name}"
  description = each.value.description
}