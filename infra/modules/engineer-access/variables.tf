variable "env_name" {
  type        = string
  description = "The name of the environment to be used in resource names."
}

variable "environment_type" {
  type        = string
  description = "The type of the environment to be used in resource names."
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

variable "pentesters" {
  type        = list(string)
  default     = []
  description = "user names for engineers to have pen testing access"
}

variable "pentester_cidrs" {
  type        = list(string)
  default     = []
  description = "CIDR blocks from which pentester IPs will come"
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

variable "codestar_connection_arn" {
  type        = string
  description = "The arn of the github connection to use"
}

variable "dynamodb_state_file_locks_table_arn" {
  type        = string
  description = "The arn of the DynamoDB table being used for state file locking"
}

variable "allow_rds_data_api_access" {
  type        = bool
  description = "Whether appropriate engineer roles should have access to the AWS RDS Data API"
}

variable "allow_ecs_task_usage" {
  type        = bool
  description = "Whether appropriate engineer roles should be able to run tasks in AWS ECS"
}