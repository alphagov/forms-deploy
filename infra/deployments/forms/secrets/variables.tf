variable "all_internal_secrets" {
  description = "Secrets for use with/by internal components in a given environment"

  type = map(object({
    name        = string
    description = string
    # by default we populate secretes with a dummy value. We can also generate a random value for it by setting this to true
    generate_random_value = optional(bool, false)
  }))
}
