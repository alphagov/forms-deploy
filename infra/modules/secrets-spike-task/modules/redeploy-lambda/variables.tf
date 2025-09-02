variable "name" {
  description = "Base name for resources (function, rule, log group)."
  type        = string
}

variable "region" {
  description = "AWS region"
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
  description = "List of Secrets Manager ARNs to watch for changes"
  type        = list(string)
}

variable "log_retention_days" {
  description = "Retention for Lambda log group"
  type        = number
  default     = 14
}

variable "secrets_account_id" {
  description = "Account ID that owns the shared EventBridge bus"
  type        = string
}

variable "secrets_account_bus_name" {
  description = "Name of the shared EventBridge bus in the secrets account"
  type        = string
  default     = "default"
}

variable "org_rule_prefix_mode" {
  description = "If true, prefix remote rule names with the caller's account ID"
  type        = bool
  default     = true
}

variable "rule_name_suffix_prefix" {
  description = "Suffix prefix used after the account ID, e.g. 'secrets-spike'"
  type        = string
  default     = "secrets-spike"
}

variable "rule_suffix" {
  description = "Rule suffix component (e.g. 'catlike-redeploy')"
  type        = string
}
