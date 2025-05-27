variable "external_env_type_secrets" {
  description = "Secrets we use to communicate with external systems, and whose values are the same in all instances of a type of environment (e.g. development or production)"

  type = map(object({
    name        = string
    description = string
  }))
}
