variable "env_name" {
  type        = string
  description = "The name of the environment to be used in resource names."
  validation {
    condition     = contains(["user-research", "deploy", "dev", "staging", "production"], var.env_name)
    error_message = "Valid values for env_name are: user-research, deploy, dev, staging, production"
  }
}

variable "admins" {
  type        = list(string)
  default     = []
  description = "user names for engineers to have admin access"
}

variable "readonly" {
  type        = list(string)
  default     = []
  description = "user names for engineers to have readonly access"
}

variable "support" {
  type        = list(string)
  default     = []
  description = "user names for engineers to have support access"
}

variable "vpn" {
  type        = bool
  default     = true
  description = "If true then user must be on the VPN to assume the role"
}
