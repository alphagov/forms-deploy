variable "external_environment_type_secrets" {
  description = "Secrets we use to communicate with external systems, and whose values are the same in all instances of a type of environment (e.g. development or review)"

  type = map(object({
    name        = string
    description = string
  }))
}

variable "external_global_secrets" {
  description = "Secrets we use to communicate with external systems, and whose values are the same across environment types. This does not mean the value is used in all environment types"

  type = map(object({
    name        = string
    description = string
  }))
}

variable "secrets_in_environment_type" {
  type = map(list(string))
}
