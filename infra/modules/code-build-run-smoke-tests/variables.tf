variable "project_name" {
  type        = string
  description = "The name of the code build project"
}

variable "project_description" {
  type        = string
  description = "The description of the code build project"
}

variable "artifact_store_arn" {
  type        = string
  description = "An S3 bucket arn where artifacts can be stored"
}

variable "signon_username_parameter_path" {
  type        = string
  description = "The path to a secure string with the signon username for smoketests"
}

variable "signon_password_parameter_path" {
  type        = string
  description = "The path to a secure string with the signon password for smoketests"
}

variable "signon_secret_parameter_path" {
  type        = string
  description = "The path to a secure string with the signon secret for smoketests"
}

variable "forms_admin_url" {
  type        = string
  description = "The url for forms admin"
}
