variable "name_prefix" {
  description = "Prefix for all resources, e.g. 'secrets-spike'"
  type        = string
}

variable "region" {
  description = "AWS region for resources (for names/ARNs/logs). Provider region should match."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the services run"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Fargate tasks"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the tasks"
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP to the tasks"
  type        = bool
  default     = false
}

variable "cpu" {
  description = "CPU units per task"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory (MiB) per task"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired task count per service"
  type        = number
  default     = 1
}

variable "container_image" {
  description = "Container image to run. If null, a public busybox image will be used."
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 7
}

variable "secrets" {
  description = "Secret ARNs from the central secrets account"
  type = object({
    catlike_arn = string
    doglike_arn = string
  })
}

variable "secrets_account_id" {
  description = "Account ID of the central secrets account that will assume the deployer role"
  type        = string
}

variable "task_execution_role_additional_policies" {
  description = "Optional additional policy ARNs to attach to the task execution role"
  type        = list(string)
  default     = []
}

variable "task_role_additional_policies" {
  description = "Optional additional policy ARNs to attach to the task role"
  type        = list(string)
  default     = []
}

variable "enable_service_auto_scaling" {
  description = "Enable Application Auto Scaling for the services"
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "Min capacity for autoscaling (only used if enabled)"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Max capacity for autoscaling (only used if enabled)"
  type        = number
  default     = 2
}

variable "autoscaling_target_cpu" {
  description = "Target CPU utilization percent for autoscaling"
  type        = number
  default     = 50
}

variable "enable_execute_command" {
  description = "Enable ECS Exec on the services"
  type        = bool
  default     = false
}

# Optional extra watched secret identifiers (ARNs or names) per service to include in EventBridge filters
variable "extra_watched_catlike" {
  description = "Additional secret identifiers (ARNs or names) to watch for catlike service"
  type        = list(string)
  default     = []
}

variable "extra_watched_doglike" {
  description = "Additional secret identifiers (ARNs or names) to watch for doglike service"
  type        = list(string)
  default     = []
}
