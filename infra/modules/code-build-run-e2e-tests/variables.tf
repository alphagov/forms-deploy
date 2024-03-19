variable "environment_name" {
  type = string
}

variable "app_name" {
  type        = string
  description = "The name of the application e.g. forms-admin"
  validation {
    condition     = contains(["forms-admin", "forms-runner", "forms-api", "forms-product-page"], var.app_name)
    error_message = "Valid values for app_name are: forms-admin, forms-runner, forms-api, forms-product-page"
  }
}

variable "artifact_store_arn" {
  type        = string
  description = "An S3 bucket arn where artifacts can be stored"
}

variable "forms_admin_url" {
  type        = string
  description = "The url for forms admin"
}

variable "product_pages_url" {
  type        = string
  description = "The url for the product pages"
}

variable "github_connection_arn" {
  type        = string
  description = "The arn of the github connection to use"
  default     = "arn:aws:codestar-connections:eu-west-2:711966560482:connection/8ad08da2-743c-4431-bee6-ad1ae9efebe7"
}

variable "service_role_arn" {
  type        = string
  description = "The arn of the service role to use"
  default     = null
}

variable "auth0_user_name_parameter_name" {
  description = "The parameter name for the username for Auth0 login into forms-admin"
  type        = string
}

variable "auth0_user_password_parameter_name" {
  description = "The parameter name for the password for Auth0 login into forms-admin"
  type        = string
}

variable "notify_api_key_parameter_name" {
  description = "The parameter name for the Notify API key to use when checking for form submissions"
  type        = string
}
