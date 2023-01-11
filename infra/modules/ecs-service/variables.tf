variable "env_name" {
  type = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.env_name)
    error_message = "Valid values for env_name are: dev, staging, production"
  }
}

variable "sub_domain" {
  type        = string
  description = "The subdomain for this service."
  validation {
    condition     = contains(["submit", "admin", "www", "api"], var.sub_domain)
    error_message = "Valid values for sub_domain are: submit, admin, www, api"
  }
}


variable "application" {
  type        = string
  description = "The name of the application e.g. forms-admin"
  validation {
    condition     = contains(["forms-admin", "forms-runner", "forms-api"], var.application)
    error_message = "Valid values for application are: forms-admin, forms-runner, forms-api"
  }
}

variable "desired_task_count" {
  type        = number
  default     = 2
  description = "How many tasks to run"
}

variable "image" {
  type        = string
  description = "The image in ECR to deploy"
}

variable "cpu" {
  type        = string
  description = "The amount of CPU to provision in the ECS task."
}

variable "memory" {
  type        = string
  description = "The amount of memory to provision in the ECS task."
}

variable "environment_variables" {
  type        = list(any)
  default     = []
  description = "Environment variables to set in the task environment"
}

variable "secrets" {
  type        = list(any)
  default     = []
  description = "Secret values to look up form SSM Parameter store and set in the task environment"
}

variable "container_port" {
  type        = number
  description = "The port that the container process listens on."
}

variable "permit_internet_egress" {
  type        = bool
  default     = false
  description = "If true then the app's security group will permit egress to the internet on port 443"
}

variable "permit_postgres_egress" {
  type        = bool
  default     = false
  description = "If true then the app's security group will permit egress to the postgres on port 5432"
}

variable "permit_redis_egress" {
  type        = bool
  default     = false
  description = "If true then the app's security group will permit egress to the redis on port 6379"
}
