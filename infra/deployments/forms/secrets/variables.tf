variable "internal_secrets" {
  description = "Secrets for use with/by internal components in the ${var.environment_name} environment"

  type = map(object({
    name        = string
    description = string
  }))
}
