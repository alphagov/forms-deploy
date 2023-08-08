variable "environment" {
  type = string

  validation {
    condition     = contains(["user-research", "dev", "staging", "production"], var.environment)
    error_message = "Valid values for environment are: user-research, dev, staging, production"
  }
}

variable "app_name" {
  type        = string
  description = "The name of the application e.g. forms-admin"
  validation {
    condition     = contains(["forms-admin", "forms-runner", "forms-api"], var.app_name)
    error_message = "Valid values for app_name are: forms-admin, forms-runner, forms-api"
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


