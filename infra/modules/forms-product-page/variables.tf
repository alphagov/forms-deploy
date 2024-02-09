variable "env_name" {
  type        = string
  description = "The name of the environment to be used in resource names."
}

variable "image_tag" {
  type     = string
  nullable = true
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "zendesk_subdomain" {
  description = "The Zendesk tenant the support form should create tickets on"
  default     = "govuk"
}

variable "admin_base_url" {
  description = "The url for redirecting to forms-admin"
  type        = string
}
variable "min_capacity" {
  description = "Sets the minimum number of instances"
  type        = number
}

variable "max_capacity" {
  description = "Sets the maximum number of instances"
  type        = number
}
