variable "project_name" {
  type        = string
  description = "The name of the code build project"
}

variable "project_description" {
  type        = string
  description = "The description of the code build project"
}

variable "deployer_role_arn" {
  type        = string
  description = "The role arn that is used to perform the cross-account deployment"
}

variable "deploy_directory" {
  type        = string
  description = "The directory to run terraform from. Root is the base of forms-deploy"
}

variable "terraform_version" {
  type        = string
  description = "The version of terraform to use"
  default     = "1.2.8"
}

variable "terraform_command" {
  type        = string
  description = "The terraform command to run including any var arguments"
  default     = "plan"
}

variable "artifact_store_arn" {
  type        = string
  description = "An S3 bucket arn where artifacts can be stored"
}
