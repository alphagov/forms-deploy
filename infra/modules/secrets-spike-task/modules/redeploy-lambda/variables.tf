variable "name" {
  description = "Base name for resources (function, rule, log group)."
  type        = string
}

variable "cluster_arn" {
  description = "Target ECS cluster ARN"
  type        = string
}

variable "service_arn" {
  description = "Target ECS service ARN"
  type        = string
}

variable "secret_arns" {
  description = "List of Secrets Manager ARNs to watch for changes (used for Lambda environment)"
  type        = list(string)
}

variable "secret_filters" {
  description = "List of secret ARNs and names for EventBridge rule filtering"
  type        = list(string)
}

variable "log_retention_days" {
  description = "Retention for Lambda log group"
  type        = number
  default     = 14
}
