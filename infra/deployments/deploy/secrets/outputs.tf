output "shared_event_bus_arn" {
  description = "ARN of the default EventBridge bus in the secrets account"
  value       = data.aws_cloudwatch_event_bus.default.arn
}

output "shared_event_bus_policy_id" {
  description = "ID of the attached EventBridge bus policy (empty string if disabled)"
  value       = try(aws_cloudwatch_event_bus_policy.org_rule_mgmt[0].id, "")
}
