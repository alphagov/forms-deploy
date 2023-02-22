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

variable "pentesters" {
  type        = list(string)
  default     = []
  description = "user names for engineers to have pen testing access"
}

variable "vpn" {
  type        = bool
  default     = true
  description = "If true then user must be on the VPN to assume the role"
}
