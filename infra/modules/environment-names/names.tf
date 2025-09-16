locals {
  environment_short_names = {
    "dev" : "dev",
    "staging" : "staging",
    "production" : "production",
    "user-research" : "ur"
  }
}

output "environment_short_names" {
  value = local.environment_short_names
}
