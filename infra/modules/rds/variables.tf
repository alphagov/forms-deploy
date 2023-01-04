variable "env_name" {
  type = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.env_name)
    error_message = "Valid values for env_name are: dev, staging, prod"
  }
}

variable "availability_zones" {
  type        = list(string)
  description = "The AZs to run the RDS cluster within"
  default     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "apply_immediately" {
  type        = bool
  description = "Whether to apply changes immediately or wait for maintenance period"
  default     = false
}

variable "main_password" {
  type        = string
  sensitive   = true
  description = "The password for the database admin user"
}

variable "backup_retention_period" {
  type        = number
  description = "How many days to keep db backups for"
  default     = 30
}

variable "auto_pause" {
  type        = bool
  description = "If true the cluster will pause when not in use"
  default     = false
}

variable "seconds_until_auto_pause" {
  type        = number
  description = "How long to wait until pauses the cluster due to inactivity"
  default     = 300
}

variable "max_capacity" {
  type        = number
  description = "The minimum Aurora Capacity Units to provision"
  default     = 2
}

variable "min_capacity" {
  type        = number
  description = "The maximum Aurora Capacity Units to provision"
  default     = 2
}

