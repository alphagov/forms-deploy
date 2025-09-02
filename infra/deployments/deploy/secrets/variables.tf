
variable "region" {
  description = "AWS region"
  type        = string
}

variable "enable_rule_management" {
  description = "Attach EventBridge bus resource policy to allow org accounts to manage namespaced rules/targets"
  type        = bool
  default     = true
}

variable "rule_name_prefix" {
  description = "Rule name prefix used in examples; enforcement is by account ID prefix"
  type        = string
  default     = "secrets-spike"
}
