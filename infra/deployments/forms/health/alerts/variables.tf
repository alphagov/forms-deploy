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

variable "zendesk_alert_topics" {
  type = object({
    us_east_1 : string
  })

  description = "The ARNs of the SNS topics to use to send an alert to Zendesk, per region"

  validation {
    condition     = alltrue([for p, arn in tomap(var.zendesk_alert_topics) : can(provider::aws::arn_parse(arn))])
    error_message = "All values must be valid ARNs"
  }
}