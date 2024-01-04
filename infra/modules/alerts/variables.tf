variable "environment" {
  type        = string
  description = "The name of the environment to be used in resource names."
}

variable "minimum_healthy_host_count" {
  type        = number
  description = "Alert will trigger if the minimum healthy host count for any ECS service drops below this number. Leaving at 0 effectively disables this alert."
  default     = 0
}

variable "enable_alert_actions" {
  type        = bool
  description = "Whether the alerts carry out the actions, for example, notifying us via Slack"
  default     = true
}