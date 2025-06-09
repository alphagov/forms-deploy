variable "internal_secrets" {
  description = "Secrets for use with/by internal components in a given environment"

  type = map(object({
    name        = string
    description = string
  }))
}
