variable "env_name" {
  type        = string
  description = "The name of the environment to be used in resource names."

  validation {
    condition     = contains(["user-research", "dev", "staging", "production"], var.env_name)
    error_message = "Valid values for env_name are: user-research, dev, staging, production"
  }
}

variable "image_tag" {
  type = string
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "admin_base_url" {
  description = "The url for redirecting to forms-admin"
  type        = string
}

variable "api_base_url" {
  description = "The url for connecting to forms-api"
  type        = string
}

variable "enable_maintenance_mode" {
  description = "Controls whether the maintenance page is shown"
  type        = bool
}

variable "maintenance_mode_bypass_ips" {
  description = "List of IP addresses which will bypass the maintenance mode message"
  type        = string
  default     = "213.86.153.211/32, 213.86.153.212/32, 213.86.153.213/32,213.86.153.214/32, 213.86.153.231/32, 213.86.153.235/32, 213.86.153.236/32, 213.86.153.237/32, 51.149.8.0/25, 51.149.8.128/29, 51.149.9.112/29, 51.149.9.240/29"
}

variable "email_confirmations_enabled" {
  description = "Toggles on/off the email confirmations feature"
  type        = bool
}

variable "rails_max_threads" {
  description = "The number of request threads run by the Puma server"
  type        = number
  default     = 25
}

variable "min_capacity" {
  description = "Sets the minimum number of instances"
  type        = number
}

variable "max_capacity" {
  description = "Sets the maximum number of instances"
  type        = number
}