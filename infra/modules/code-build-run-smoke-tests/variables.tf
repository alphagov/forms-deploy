variable "environment" {
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


variable "github_connection_arn" {
  type        = string
  description = "The arn of the github connection to use"
  default     = "arn:aws:codestar-connections:eu-west-2:711966560482:connection/8ad08da2-743c-4431-bee6-ad1ae9efebe7"
}
