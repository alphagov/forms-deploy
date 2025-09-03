output "shared_event_bus_arn" {
  description = "ARN of the custom shared EventBridge bus in the secrets account"
  value       = aws_cloudwatch_event_bus.shared.arn
}

output "shared_event_bus_name" {
  description = "Name of the custom shared EventBridge bus"
  value       = aws_cloudwatch_event_bus.shared.name
}

output "shared_event_bus_policy_id" {
  description = "ID of the attached EventBridge bus policy (empty string if disabled)"
  value       = try(aws_cloudwatch_event_bus_policy.org_rule_mgmt[0].id, "")
}
