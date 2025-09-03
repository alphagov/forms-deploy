output "forward_rule_name" {
  description = "Name of the EventBridge forwarder rule on default bus"
  value       = aws_cloudwatch_event_rule.forward_secrets.name
}

output "forward_rule_arn" {
  description = "ARN of the EventBridge forwarder rule on default bus"
  value       = aws_cloudwatch_event_rule.forward_secrets.arn
}

output "forward_target_arns_by_env" {
  description = "Map of environment names to target default bus ARNs"
  value = {
    for env_name, account_id in module.all_accounts.environment_accounts_id :
    env_name => "arn:aws:events:${data.aws_region.this.name}:${account_id}:event-bus/default"
  }
}

output "forward_role_arn" {
  description = "ARN of the IAM role used by EventBridge to forward events to environment accounts (reused from coordination)"
  value       = data.aws_iam_role.eventbridge_actor.arn
}
